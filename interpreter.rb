require 'byebug'

class Interpreter
  attr_accessor :arr_memory, :ram_memory

  def initialize(file)
    @out = false
    @arr_memory = []
    @ram_memory = { mem: nil, ind: nil, target_label: nil, keep_skiping: false, current_line: 0, file: file}
  end

  def execute(file = ram_memory[:file], start = 0, final = File.open(ram_memory[:file]).readlines.size)
    # binding.irb
    IO.readlines(file)[start..final].each.with_index do |line, index|
      ram_memory[:current_line] = index
      # binding.irb if ram_memory[:current_line] >= 31 && @out == false
      # binding.irb if line.chomp == 'label'
      next if skip_line?(line)

      line = line.chomp.split(' ')
      action = line.shift
      # puts line.to_s
      # binding.irb if action == 'repeat'
      send("#{action}".to_sym, line.join(' '))
      # puts "#{action}".to_sym, line.join(' ')
      # p arr_memory
      # p ram_memory
      # puts '------'
      # sleep 1
    end
  end

  def skip_line?(line)

    return true if line.chars[0] == "#"
    return true if line == "\n"

    current_line = line.chomp.split(' ')

    line_has_label = current_line.first == 'label'

    if ram_memory[:keep_skiping]
      return false if current_line == 'end_repeat'

      return true unless line_has_label

      return true if current_line.last != ram_memory[:target_label]

      ram_memory[:target_label] = nil
      ram_memory[:keep_skiping] = false
      return true
    end

    return true if line_has_label

    false
  end

  def keyboard(*args)
    arr_memory << STDIN.gets.chomp.to_i
  end

  def store(memory)
    memory = memory.delete(' ').split('->').last
    ram_memory["#{memory}".to_sym] = arr_memory.pop
  end

  def read(memory)
    memory = memory.split(' ').last
    arr_memory << ram_memory["#{memory}".to_sym]
  end

  def if(args)
    args = args.split(' ')
    action = args.shift
    # binding.irb if ram_memory[:current_line] >= 30 && @out == false

    send("#{action}".to_sym, args.join(' '))
    if arr_memory.last == true && !args.join(' ').empty?
      ram_memory[:keep_skiping] = true
      ram_memory[:target_label] = args.last
    end
  end

  def equal(*args)
    update_arr_memmory_taking_first_two('==')
  end

  def less(*args)
    update_arr_memmory_taking_first_two('<')
  end

  def less_than(*args)
    update_arr_memmory_taking_first_two('<=')
  end

  def greater_than(*args)
    update_arr_memmory_taking_first_two('>=')
  end

  def greater(*args)
    update_arr_memmory_taking_first_two('>')
  end

  def sum(*args)
    update_arr_memmory_taking_first_two('+')
  end

  def module(*args)
    update_arr_memmory_taking_first_two('%')
  end

  def update_arr_memmory_taking_first_two(method)
    # binding.irb if method == '<'
    first_number, second_number = (1..2).map{ |num| arr_memory.pop }
    result = eval("#{second_number} #{method} #{first_number}")
    arr_memory << result
    result
  end

  def push(input)
    is_not_integer = Integer(input, exception: false).nil?
    input = is_not_integer ? input : input.to_i
    arr_memory << input
  end

  def pop(*args)
    arr_memory.pop
  end

  def end(*args)
    exit
  end

  def print(*args)
    puts "RESULTADO: " + arr_memory.pop
  end

  def repeat(text)
    arr = text
    # binding.irb if ram_memory[:current_line] >= 31 && @out == false

    send("#{text}".to_sym)
    # binding.irb
    if arr_memory.last == false
      ram_memory[:keep_skiping] = true
    else
      ram_memory[:keep_skiping] = false
    end
    # binding.irb
    # ram_memory[:keep_skiping] = true if arr_memory.first == true
    # ram_memory[:keep_skiping] = false if arr_memory.first == false

    current_line = ram_memory[:current_line] + 1

    ram_memory[:last_line] = IO.readlines("input.file")[0..].each.find_index { |line| line.include?('end_repeat') }
# binding.irb
    execute("input.file", current_line, ram_memory[:last_line])
  end

  def end_repeat(*args)
    # binding.irb
    ram_memory[:keep_skiping] = false
  end

end

Interpreter.new("#{ARGV[0]}").execute
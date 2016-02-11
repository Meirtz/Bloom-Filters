def fvn_1 (str)
  hash = 2166136261               # 32 bit offset_basis = 2166136261
  str.each_byte do |byte|
    hash ^= byte
    hash *= 16777619              # 32 bit FNV_prime = 2^24 + 2^8 + 0x93 = 16777619
  end
  hash % 2048 # define maximal hash value
end

def hash_index (str)
  x = fvn_1(str)
  y = str.hash % 2048
  [x, y]
end

def str_to_bit_array (str, bit_array)
  x, y = hash_index(str)
  bit_array[x] = 1
  bit_array[y] = 1
end

def check (str, bit_array)
  x, y = hash_index(str)
  return true if bit_array[x] == 1 and bit_array[y] == 1
  return false
end


# bitarray 0.0.5 by peterc under MIT license. Copyright 2007-2013 Peter Cooper, yada yada.
# or use 'gem install bitarray' to install
class BitArray
  attr_reader :size
  attr_reader :field
  include Enumerable

  VERSION = "0.0.5"
  ELEMENT_WIDTH = 32

  def initialize(size, field = nil)
    @size = size
    @field = field || Array.new(((size - 1) / ELEMENT_WIDTH) + 1, 0)
  end

  # Set a bit (1/0)
  def []=(position, value)
    if value == 1
      @field[position / ELEMENT_WIDTH] |= 1 << (position % ELEMENT_WIDTH)
    elsif (@field[position / ELEMENT_WIDTH]) & (1 << (position % ELEMENT_WIDTH)) != 0
      @field[position / ELEMENT_WIDTH] ^= 1 << (position % ELEMENT_WIDTH)
    end
  end

  # Read a bit (1/0)
  def [](position)
    @field[position / ELEMENT_WIDTH] & 1 << (position % ELEMENT_WIDTH) > 0 ? 1 : 0
  end

  # Iterate over each bit
  def each(&block)
    @size.times { |position| yield self[position] }
  end

  # Returns the field as a string like "0101010100111100," etc.
  def to_s
    @field.collect{|ea| ("%032b" % ea).reverse}.join[0..@size-1]
  end

  # Returns the total number of bits that are set
  # (The technique used here is about 6 times faster than using each or inject direct on the bitfield)
  def total_set
    @field.inject(0) { |a, byte| a += byte & 1 and byte >>= 1 until byte == 0; a }
  end
end

#puts fvn_1 "hello"
str_array = ["wo", "bc", "jiu", "shi", "diao"]
bit_array = BitArray.new(2048)

# save hashed bit info to bit_array
str_array.each() { |str| str_to_bit_array(str, bit_array) }

#check example
puts "maybe" if check("bc",bit_array) or puts "never"
puts "maybe" if check("meirtz",bit_array) or puts "never"

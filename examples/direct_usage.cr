# Example of using C bindings directly
# Equivalent C code: https://github.com/taku910/mecab/blob/master/mecab/example/example.c

require "../src/wakame/lib/*"

macro check(eval)
  if !{{eval}}
    message = LibMeCab.strerror(mecab)
    puts "Exception: #{String.new(message)}"
    LibMeCab.destroy(mecab)
    exit -1
  end
end

input = "太郎は次郎が持っている本を花子に渡した。"

mecab = LibMeCab.new2("")
check mecab

result = LibMeCab.sparse_tostr(mecab, input)
check result
puts "INPUT: #{input}"
puts "RESULT:\n#{String.new(result)}"

result = LibMeCab.nbest_sparse_tostr(mecab, 3, input)
check result
puts "NBEST:\n#{String.new(result)}"

check LibMeCab.nbest_init(mecab, input)
3.times do |i|
  str = LibMeCab.nbest_next_tostr(mecab)
  puts "#{i}:\n#{String.new(str)}"
end

node = LibMeCab.sparse_tonode(mecab, input)
check node
while !node.null?
  value = node.value
  if value.stat == LibMeCab::NorNode || value.stat == LibMeCab::UnkNode
    puts "#{String.new(Slice.new(value.surface, value.length))}" \
         "\t#{String.new(value.feature)}"
  end
  node = node.value.next
end

dict_info = LibMeCab.dictionary_info(mecab)
while !dict_info.null?
  value = dict_info.value
  puts "filename: #{String.new(value.filename)}"
  puts "charset: #{String.new(value.charset)}"
  puts "size: #{value.size}"
  puts "type: #{value.type}"
  puts "lsize: #{value.lsize}"
  puts "rsize: #{value.rsize}"
  puts "version: #{value.version}"
  dict_info = dict_info.value.next
end

LibMeCab.destroy(mecab)

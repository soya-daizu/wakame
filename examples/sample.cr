require "../src/wakame"

mecab = Wakame::MeCab.new

puts mecab.parse("吾輩は猫である。名前はまだ無い。")
mecab.parse("吾輩は猫である。名前はまだ無い。") do |node|
  puts "#{node.surface},#{node.feature}" if !node.bos_node? && !node.eos_node?
end

puts mecab.parse("外国人参政権")
puts mecab.parse("外国人参政権", /外国|人/)

puts mecab.parse("邪神ちゃんドロップキーック！")
puts mecab.parse("邪神ちゃんドロップキーック！", {"邪神ちゃん" => "*", "キーック" => "*"})

mecab = Wakame::MeCab.new(node_format: "%pS%f[7]\\s", eos_format: "\\0")
puts mecab.parse("吾輩は猫である。名前はまだ無い。")

mecab = Wakame::MeCab.new("-F %pS%f[7]\\s -E \\0")
puts mecab.parse("吾輩は猫である。名前はまだ無い。")

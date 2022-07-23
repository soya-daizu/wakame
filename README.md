# Wakame

Wakame is a Crystal binding for MeCab([Website](https://taku910.github.io/mecab)/[Wikipedia](https://en.wikipedia.org/wiki/MeCab)), a morphological analyzer written in C++ often used to analyze Japanese texts. Wakame aims to provide natural interfaces to MeCab in Crystal.

## Dependencies

- [MeCab](https://taku910.github.io/mecab/#download)
  - You may also need to install `libmecab-dev` if you are installing from the package manager
- One of the system dictionaries available on the [website](https://taku910.github.io/mecab/#download) or a third-party system dictionary like [mecab-ipadic-NEologd](https://github.com/neologd/mecab-ipadic-neologd)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     wakame:
       github: soya-daizu/wakame
   ```

2. Run `shards install`

## Usage

```crystal
mecab = Wakame::MeCab.new

puts mecab.parse("吾輩は猫である。名前はまだ無い。")
# => 吾輩 名詞,代名詞,一般,*,*,*,吾輩,ワガハイ,ワガハイ
#    は 助詞,係助詞,*,*,*,*,は,ハ,ワ
#    猫 名詞,一般,*,*,*,*,猫,ネコ,ネコ
#    で 助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
#    ある  助動詞,*,*,*,五段・ラ行アル,基本形,ある,アル,アル
#    。 記号,句点,*,*,*,*,。,。,。
#    名前  名詞,一般,*,*,*,*,名前,ナマエ,ナマエ
#    は 助詞,係助詞,*,*,*,*,は,ハ,ワ
#    まだ  副詞,助詞類接続,*,*,*,*,まだ,マダ,マダ
#    無い  形容詞,自立,*,*,形容詞・アウオ段,基本形,無い,ナイ,ナイ
#    。 記号,句点,*,*,*,*,。,。,。
#    EOS

mecab.parse("吾輩は猫である。名前はまだ無い。") do |node|
  puts "#{node.surface},#{node.feature}" if !node.bos_node? && !node.eos_node?
end
# => 吾輩,名詞,代名詞,一般,*,*,*,吾輩,ワガハイ,ワガハイ
#    は,助詞,係助詞,*,*,*,*,は,ハ,ワ
#    猫,名詞,一般,*,*,*,*,猫,ネコ,ネコ
#    で,助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
#    ある,助動詞,*,*,*,五段・ラ行アル,基本形,ある,アル,アル
#    。,記号,句点,*,*,*,*,。,。,。
#    名前,名詞,一般,*,*,*,*,名前,ナマエ,ナマエ
#    は,助詞,係助詞,*,*,*,*,は,ハ,ワ
#    まだ,副詞,助詞類接続,*,*,*,*,まだ,マダ,マダ
#    無い,形容詞,自立,*,*,形容詞・アウオ段,基本形,無い,ナイ,ナイ
#    。,記号,句点,*,*,*,*,。,。,。


puts mecab.parse("外国人参政権")
# => 外国    名詞,一般,*,*,*,*,外国,ガイコク,ガイコク
#    人参    名詞,一般,*,*,*,*,人参,ニンジン,ニンジン
#    政権    名詞,一般,*,*,*,*,政権,セイケン,セイケン
#    EOS

# Giving MeCab hints with boundary constraints
puts mecab.parse("外国人参政権", /外国|人/)
# => 外国    名詞,一般,*,*,*,*,外国,ガイコク,ガイコク
#    人      名詞,接尾,一般,*,*,*,人,ジン,ジン
#    参政    名詞,サ変接続,*,*,*,*,参政,サンセイ,サンセイ
#    権      名詞,接尾,一般,*,*,*,権,ケン,ケン
#    EOS


puts mecab.parse("邪神ちゃんドロップキーック！")
# => 邪神 名詞,一般,*,*,*,*,邪神,ジャシン,ジャシン
#    ちゃん 名詞,接尾,人名,*,*,*,ちゃん,チャン,チャン
#    ドロップキーック  名詞,一般,*,*,*,*,*
#    ！ 記号,一般,*,*,*,*,！,！,！
#    EOS

# Giving MeCab hints with feature constraints
puts mecab.parse("邪神ちゃんドロップキーック！", {"邪神ちゃん" => "*", "キーック" => "*"})
# => 邪神ちゃん  名詞,一般,*,*,*,*,*
#    ドロップ  名詞,一般,*,*,*,*,ドロップ,ドロップ,ドロップ
#    キーック  名詞,一般,*,*,*,*,*
#    ！ 記号,一般,*,*,*,*,！,！,！
#    EOS

# These two are identical

mecab = Wakame::MeCab.new(node_format: "%pS%f[7]\\s", eos_format: "\\0")
puts mecab.parse("吾輩は猫である。名前はまだ無い。")
# => ワガハイ ハ ネコ デ アル 。 ナマエ ハ マダ ナイ 。

mecab = Wakame::MeCab.new("-F %pS%f[7]\\s -E \\0")
puts mecab.parse("吾輩は猫である。名前はまだ無い。")
# => ワガハイ ハ ネコ デ アル 。 ナマエ ハ マダ ナイ 。
```

## Contributing

1. Fork it (<https://github.com/soya-daizu/wakame/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [soya_daizu](https://github.com/soya-daizu) - creator and maintainer

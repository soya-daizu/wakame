require "./**"

module Wakame
  # `MeCab` is the primary class to interact with the MeCab library.
  #
  # It can be initialized by passing either a complete `Wakame::Options` object,
  # or a series of arguments to be passed to the underlying `Wakame::Options` object,
  # or a string of option arguments in command line format.
  #
  # ```
  # require "wakame"
  #
  # mecab = Wakame::MeCab.new
  # puts mecab.parse("吾輩は猫である。名前はまだ無い。")
  # # => 吾輩    名詞,代名詞,一般,*,*,*,吾輩,ワガハイ,ワガハイ
  # #    は      助詞,係助詞,*,*,*,*,は,ハ,ワ
  # #    猫      名詞,一般,*,*,*,*,猫,ネコ,ネコ
  # #    で      助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
  # #    ある    助動詞,*,*,*,五段・ラ行アル,基本形,ある,アル,アル
  # #    。      記号,句点,*,*,*,*,。,。,。
  # #    名前    名詞,一般,*,*,*,*,名前,ナマエ,ナマエ
  # #    は      助詞,係助詞,*,*,*,*,は,ハ,ワ
  # #    まだ    副詞,助詞類接続,*,*,*,*,まだ,マダ,マダ
  # #    無い    形容詞,自立,*,*,形容詞・アウオ段,基本形,無い,ナイ,ナイ
  # #    。      記号,句点,*,*,*,*,。,。,。
  # #    EOS
  #
  # mecab.parse("吾輩は猫である。名前はまだ無い。") do |node|
  #   puts "#{node.surface},#{node.feature}" if !node.bos_node? && !node.eos_node?
  # end
  # # => 吾輩,名詞,代名詞,一般,*,*,*,吾輩,ワガハイ,ワガハイ
  # #    は,助詞,係助詞,*,*,*,*,は,ハ,ワ
  # #    猫,名詞,一般,*,*,*,*,猫,ネコ,ネコ
  # #    で,助動詞,*,*,*,特殊・ダ,連用形,だ,デ,デ
  # #    ある,助動詞,*,*,*,五段・ラ行アル,基本形,ある,アル,アル
  # #    。,記号,句点,*,*,*,*,。,。,。
  # #    名前,名詞,一般,*,*,*,*,名前,ナマエ,ナマエ
  # #    は,助詞,係助詞,*,*,*,*,は,ハ,ワ
  # #    まだ,副詞,助詞類接続,*,*,*,*,まだ,マダ,マダ
  # #    無い,形容詞,自立,*,*,形容詞・アウオ段,基本形,無い,ナイ,ナイ
  # #    。,記号,句点,*,*,*,*,。,。,。
  #
  # # These two are equivalent
  # mecab = Wakame::MeCab.new(node_format: "%pS%f[7]\\s", eos_format: "\\0")
  # puts mecab.parse("吾輩は猫である。名前はまだ無い。")
  # # => ワガハイ ハ ネコ デ アル 。 ナマエ ハ マダ ナイ 。
  #
  # mecab = Wakame::MeCab.new("-F %pS%f[7]\\s -E \\0")
  # puts mecab.parse("吾輩は猫である。名前はまだ無い。")
  # # => ワガハイ ハ ネコ デ アル 。 ナマエ ハ マダ ナイ 。
  # ```
  class MeCab
    private macro handle_lattice_error
      message = String.new(LibMeCab.lattice_strerror(@lattice))
      raise ex if message.empty?
      raise WakameError.new(message)
    end

    getter model, tagger, lattice, libpath, options, dicts, version

    # Creates a new MeCab instance from the given option arguments.
    # These arguments are first forwarded to instantiate the underlying
    # `Wakame::Options` object that is needed to instantiate itself.
    #
    # See `Wakame::Options` for the all available options.
    def self.new(**option_args)
      options = Options.new(**option_args)
      self.new(options)
    end

    # Creates a new MeCab instance from the given string of option arguments
    # in the style of MeCab's command line interface.
    def self.new(option_str : String)
      options = Options.new(option_str)
      self.new(options)
    end

    # Creates a new MeCab instance with the given `Wakame::Options` object.
    def initialize(@options : Options)
      option_str = @options.build_str

      # The tagger is not initialized as of the first check call,
      # and this is to satisfy the compiler that requires its type information
      # before it is initialized after the first check.
      @tagger = uninitialized LibMeCab::T*

      @model = LibMeCab.model_new2(option_str)
      check(@model, "Could not initialize Model with options: \"#{option_str}\"")

      @tagger = LibMeCab.model_new_tagger(@model)
      check(@tagger, "Could not initialize Tagger with options: \"#{option_str}\"")

      @lattice = LibMeCab.model_new_lattice(@model)
      check(@lattice, "Could not initialize Lattice with options: \"#{option_str}\"")

      LibMeCab.lattice_set_request_type(@lattice, @options.nbest || 1 > 1 ? LibMeCab::Nbest : LibMeCab::OneBest)
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::Partial) if @options.partial
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::MarginalProb) if @options.marginal
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::AllMorphs) if @options.all_morphs
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::AllocateSentence) if @options.allocate_sentence

      LibMeCab.lattice_set_theta(@lattice, @options.theta.not_nil!) if @options.theta

      @dicts = [] of DictionaryInfo
      @dicts << DictionaryInfo.new(LibMeCab.model_dictionary_info(@model))
      while next_dic = @dicts.last.next
        @dicts << next_dic
      end

      @version = LibMeCab.version
    end

    private def check(eval, message)
      return if eval
      mecab_message = String.new(LibMeCab.strerror(@tagger)) if @tagger
      raise WakameError.new(message) if !mecab_message || mecab_message.empty?
      raise WakameError.new(mecab_message)
    end

    # :nodoc:
    def finalize
      LibMeCab.destroy(@tagger)
      LibMeCab.lattice_destroy(@lattice)
      LibMeCab.model_destroy(@model)
    end

    # Parses the given text, returning the MeCab output as a single String.
    def parse(text : String)
      LibMeCab.lattice_set_sentence(@lattice, text)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    # Parses the given text, yielding each node to the given block.
    def parse(text : String, &block : MeCabNode ->)
      LibMeCab.lattice_set_sentence(@lattice, text)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    # Parses the given text with boundary constraints,
    # returning the MeCab output as a single String.
    #
    # Boundary constraints provide hints to MeCab on where
    # the morpheme boundaries are located in the given text.
    # ```
    # mecab = Wakame::MeCab.new
    # # Without using boundary constraints
    # puts mecab.parse("外国人参政権")
    # # => 外国    名詞,一般,*,*,*,*,外国,ガイコク,ガイコク
    # #    人参    名詞,一般,*,*,*,*,人参,ニンジン,ニンジン
    # #    政権    名詞,一般,*,*,*,*,政権,セイケン,セイケン
    # #    EOS
    #
    # # Giving MeCab hints with boundary constraints
    # puts mecab.parse("外国人参政権", /外国|人/)
    # # => 外国    名詞,一般,*,*,*,*,外国,ガイコク,ガイコク
    # #    人      名詞,接尾,一般,*,*,*,人,ジン,ジン
    # #    参政    名詞,サ変接続,*,*,*,*,参政,サンセイ,サンセイ
    # #    権      名詞,接尾,一般,*,*,*,権,ケン,ケン
    # #    EOS
    # ```
    def parse(text : String, boundary_constraints : Regex | String)
      set_boundary_constraints(text, boundary_constraints)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    # Parses the given text with boundary constraints,
    # yielding each node to the given block.
    #
    # See `#parse(text : String, boundary_constraints : Regex | String)` for details.
    def parse(text : String, boundary_constraints : Regex | String, &block : MeCabNode ->)
      set_boundary_constraints(text, boundary_constraints)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    # Parses the given text with feature constraints,
    # returning the MeCab output as a single String.
    #
    # Feature constraints provide instructions to MeCab to use
    # a specific feature for any morphemes that match the given key.
    # Set the morpheme String as a key and the feature String as the value.
    # Wildcard "*" can be used as the feature to let MeCab decide which feature to use.
    #
    # ```
    # mecab = Wakame::MeCab.new
    # # Without using feature constraints
    # puts mecab.parse("邪神ちゃんドロップキーック！")
    # # => 邪神    名詞,一般,*,*,*,*,邪神,ジャシン,ジャシン
    # #    ちゃん  名詞,接尾,人名,*,*,*,ちゃん,チャン,チャン
    # #    ドロップキーック        名詞,一般,*,*,*,*,*
    # #    ！      記号,一般,*,*,*,*,！,！,！
    # #    EOS
    #
    # # Giving MeCab hints with feature constraints
    # puts mecab.parse("邪神ちゃんドロップキーック！", {"邪神ちゃん" => "*", "キーック" => "*"})
    # # => 邪神ちゃん      名詞,一般,*,*,*,*,*
    # #    ドロップ        名詞,一般,*,*,*,*,ドロップ,ドロップ,ドロップ
    # #    キーック        名詞,一般,*,*,*,*,*
    # #    ！      記号,一般,*,*,*,*,！,！,！
    # #    EOS
    # ```
    def parse(text : String, feature_constraints : Hash(String, String))
      set_feature_constraints(text, feature_constraints)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    # Parses the given text with feature constraints,
    # yielding each node to the given block.
    #
    # See `#parse(text : String, feature_constraints : Hash(String, String))` for details.
    def parse(text : String, feature_constraints : Hash(String, String), &block : MeCabNode ->)
      set_feature_constraints(text, feature_constraints)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    private def set_boundary_constraints(text : String, constraints : Regex | String)
      tokens = tokenize_by_pattern(text, constraints)
      text = tokens.map(&.first).join if !tokens.empty?
      LibMeCab.lattice_set_sentence(@lattice, text)

      bpos = 0
      tokens.each do |token|
        c = token.first.bytesize

        LibMeCab.lattice_set_boundary_constraint(@lattice, bpos, LibMeCab::TokenBoundary)
        bpos += 1

        mark = token.last ? LibMeCab::InsideToken : LibMeCab::AnyBoundary
        (c - 1).times do
          LibMeCab.lattice_set_boundary_constraint(@lattice, bpos, mark)
          bpos += 1
        end
      end
    end

    private def set_feature_constraints(text : String, constraints : Hash(String, String))
      tokens = tokenize_by_features(text, constraints.keys)
      text = tokens.map(&.first).join if !tokens.empty?
      LibMeCab.lattice_set_sentence(@lattice, text)

      bpos = 0
      tokens.each do |token|
        chunk = token.first
        c = chunk.bytesize
        if token.last
          LibMeCab.lattice_set_feature_constraint(
            @lattice,
            bpos,
            bpos + c,
            constraints[chunk]
          )
        end
        bpos += c
      end
    end

    private def parse_lattice_tostr
      LibMeCab.parse_lattice(@tagger, @lattice)

      if n = @options.nbest
        retval = LibMeCab.lattice_nbest_tostr(@lattice, n)
      else
        retval = LibMeCab.lattice_tostr(@lattice)
      end
      String.new(retval)
    end

    private def parse_lattice_tonodes
      LibMeCab.parse_lattice(@tagger, @lattice)

      (@options.nbest || 1).times do
        next unless LibMeCab.lattice_next(@lattice)
        node_ptr = LibMeCab.lattice_get_bos_node(@lattice)
        while node_ptr
          node = MeCabNode.new(node_ptr, @tagger)
          yield node
          node_ptr = node_ptr.value.next
        end
      end
    end

    private def tokenize_by_pattern(text : String, pattern : Regex | String)
      matches = text.scan(pattern)

      tokens = [] of Tuple(String, Bool)
      tmp = text
      matches.each_with_index do |m, i|
        match_str = m.is_a?(Regex::MatchData) ? m[0] : m
        before, match, after = tmp.partition(match_str)
        tokens << {before.strip, false} unless before.empty?
        tokens << {match.strip, true} unless match.empty?
        tokens << {after.strip, false} if i == matches.size - 1 && !after.empty?
        tmp = after
      end
      tokens
    end

    private def tokenize_by_features(text : String, features : Array(String))
      tokens = [] of Tuple(String, Bool)
      tokens << {text.strip, false}

      features.each do |feature|
        tokens.each_with_index do |t, i|
          next if t.last
          tmp = tokenize_by_pattern(t.first, feature)
          next if tmp.empty?
          tokens[i, 1] = tmp
        end
      end
      tokens
    end
  end

  # Generic error type for the `Wakame` module.
  class WakameError < Exception; end
end

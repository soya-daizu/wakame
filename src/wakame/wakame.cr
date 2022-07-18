require "./**"

module Wakame
  class MeCab
    macro handle_lattice_error
      message = String.new(LibMeCab.lattice_strerror(@lattice))
      raise ex if message.empty?
      raise WakameError.new(message)
    end

    getter model, tagger, lattice, libpath, options, dicts, version

    def self.new(**option_args)
      options = Options.new(**option_args)
      self.new(options)
    end

    def self.new(option_str : String)
      options = Options.new(option_str)
      self.new(options)
    end

    def initialize(@options : Options)
      @tagger = uninitialized LibMeCab::T*

      opt_str = @options.build_str

      @model = LibMeCab.model_new2(opt_str)
      check(@model, "Could not initialize Model with options: \"#{opt_str}\"")

      @tagger = LibMeCab.model_new_tagger(@model)
      check(@tagger, "Could not initialize Tagger with options: \"#{opt_str}\"")

      @lattice = LibMeCab.model_new_lattice(@model)
      check(@lattice, "Could not initialize Lattice with options: \"#{opt_str}\"")

      LibMeCab.lattice_set_request_type(@lattice, @options.nbest || 1 > 1 ? LibMeCab::Nbest : LibMeCab::OneBest)
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::Partial) if @options.partial
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::MarginalProb) if @options.marginal
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::AllMorphs) if @options.all_morphs
      LibMeCab.lattice_add_request_type(@lattice, LibMeCab::AllocateSentence) if @options.allocate_sentence

      LibMeCab.lattice_set_theta(@lattice, @options.theta.not_nil!) if @options.theta

      @dicts = [] of DictionaryInfo
      @dicts << DictionaryInfo.new(LibMeCab.model_dictionary_info(@model))
      while @dicts.last.next
        @dicts << DictionaryInfo.new(@dicts.last.next)
      end

      @version = LibMeCab.version
    end

    def check(eval, message)
      return if eval
      mecab_message = String.new(LibMeCab.strerror(@tagger)) if @tagger
      raise WakameError.new(message) if !mecab_message || mecab_message.empty?
      raise WakameError.new(mecab_message)
    end

    def finalize
      LibMeCab.destroy(@tagger)
      LibMeCab.lattice_destroy(@lattice)
      LibMeCab.model_destroy(@model)
    end

    def parse(text : String)
      LibMeCab.lattice_set_sentence(@lattice, text)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    def parse(text : String, &block : MeCabNode ->)
      LibMeCab.lattice_set_sentence(@lattice, text)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    def parse(text : String, boundary_constraints : Regex | String)
      set_boundary_constraints(text, boundary_constraints)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    def parse(text : String, boundary_constraints : Regex | String, &block : MeCabNode ->)
      set_boundary_constraints(text, boundary_constraints)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    def parse(text : String, feature_constraints : Hash(String, String))
      set_feature_constraints(text, feature_constraints)
      parse_lattice_tostr
    rescue ex
      handle_lattice_error
    end

    def parse(text : String, feature_constraints : Hash(String, String), &block : MeCabNode ->)
      set_feature_constraints(text, feature_constraints)
      parse_lattice_tonodes(&block)
    rescue ex
      handle_lattice_error
    end

    private def set_boundary_constraints(text : String, constraints : Regex | String)
      tokens = tokenize_by_pattern(text, constraints)
      text = tokens.map(&.first).join
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
      text = tokens.map(&.first).join
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
          node = MeCabNode.new(node_ptr)
          yield node
          node_ptr = node.next
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

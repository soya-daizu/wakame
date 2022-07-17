require "./**"

module Wakame
  class MeCab
    macro handle_lattice_error
      message = String.new(LibMeCab.lattice_strerror(@lattice))
      raise ex if message.empty?
      raise WakameError.new(message)
    end

    getter model, mecab, lattice

    def initialize(**options)
      @tagger = uninitialized LibMeCab::T*

      @options = Options.new(**options)
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
  end

  # Generic error type for the `Wakame` module.
  class WakameError < Exception; end
end

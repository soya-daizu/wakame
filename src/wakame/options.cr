module Wakame
  struct Options
    getter rcfile : String?
    getter dicdir : String?
    getter userdic : String?
    getter lattice_level : Int32?
    getter output_format_type : String?
    getter all_morphs : Bool?
    getter nbest : Int32?
    getter partial : Bool?
    getter marginal : Bool?
    getter max_grouping_size : Int32?
    getter node_format : String?
    getter unk_format : String?
    getter bos_format : String?
    getter eos_format : String?
    getter eon_format : String?
    getter unk_feature : String?
    getter input_buffer_size : Int32?
    getter allocate_sentence : Bool?
    getter theta : Float32?
    getter cost_factor : Int32?

    def initialize(@rcfile = nil, @dicdir = nil, @userdic = nil,
                   @lattice_level = nil, @output_format_type = nil, @all_morphs = nil,
                   @nbest = nil, @partial = nil, @marginal = nil,
                   @max_grouping_size = nil, @node_format = nil, @unk_format = nil,
                   @bos_format = nil, @eos_format = nil, @eon_format = nil,
                   @unk_feature = nil, @input_buffer_size = nil, @allocate_sentence = nil,
                   @theta = nil, @cost_factor = nil)
      if n = @nbest
        raise WakameError.new("Invalid N value") if n < 1 || n > 512
      end
    end

    def build_str
      names = {{ @type.instance_vars.map &.name.stringify }}
      values = {{ @type.instance_vars }}

      options = names.zip(values).compact_map do |name, value|
        next unless value
        next "--#{name.gsub('_', '-')}" if value.is_a?(Bool)
        next "--#{name.gsub('_', '-')} \"#{value}\"" if value.is_a?(String)
        "--#{name.gsub('_', '-')} #{value}"
      end

      options.join(" ")
    end
  end
end

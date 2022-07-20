require "option_parser"

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

    protected setter(
      rcfile, dicdir, userdic,
      lattice_level, output_format_type, all_morphs,
      nbest, partial, marginal,
      max_grouping_size, node_format, unk_format,
      bos_format, eos_format, eon_format,
      unk_feature, input_buffer_size, allocate_sentence,
      theta, cost_factor
    )

    # Creates a new options object with the given command-line style option arguments.
    def self.new(option_str : String)
      options = self.new

      parser = OptionParser.new(gnu_optional_args: true)
      parser.on("-r FILE", "--rcfile FILE", "") { |file| options.rcfile = file }
      parser.on("-d DIR", "--dicdir DIR", "") { |dir| options.dicdir = dir }
      parser.on("-u FILE", "--userdic FILE", "") { |file| options.userdic = file }
      parser.on("-l INT", "--lattice-level INT", "") { |int| options.lattice_level = int.to_i }
      parser.on("-O TYPE", "--output-format-type TYPE", "") { |type| options.output_format_type = type }
      parser.on("-a", "--all-morphs", "") { options.all_morphs = true }
      parser.on("-N INT", "--nbest INT", "") do |int|
        nbest = int.to_i
        raise WakameError.new("Invalid N value") if nbest < 1 || nbest > 512
        options.nbest = nbest
      end
      parser.on("-p", "--partial", "") { options.partial = true }
      parser.on("-m", "--marginal", "") { options.marginal = true }
      parser.on("-M INT", "--max-grouping-size INT", "") { |int| options.max_grouping_size = int.to_i }
      parser.on("-F STR", "--node-format STR", "") { |str| options.node_format = str }
      parser.on("-U STR", "--unk-format STR", "") { |str| options.unk_format = str }
      parser.on("-B STR", "--bos-format STR", "") { |str| options.bos_format = str }
      parser.on("-E STR", "--eos-format STR", "") { |str| options.eos_format = str }
      parser.on("-S STR", "--eon-format STR", "") { |str| options.eon_format = str }
      parser.on("-x STR", "--unk-feature STR", "") { |str| options.unk_feature = str }
      parser.on("-b INT", "--input-buffer-size INT", "") { |int| options.input_buffer_size = int.to_i }
      parser.on("-C", "--allocate-sentence", "") { options.allocate_sentence = true }
      parser.on("-t FLOAT", "--theta FLOAT", "") { |float| options.theta = float.to_f32 }
      parser.on("-c INT", "--cost-factor INT", "") { |int| options.cost_factor = int.to_i }

      parser.parse(option_str.split)

      options
    end

    # Creates a new object that represents a collection of the given option arguments
    # to pass to the Wakame::MeCab object.
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

    protected def build_str
      names = {{ @type.instance_vars.map &.name.stringify }}
      values = {{ @type.instance_vars }}

      options = names.zip(values).compact_map do |name, value|
        next unless value
        next "--#{name.gsub('_', '-')}" if value.is_a?(Bool)
        "--#{name.gsub('_', '-')}=#{value}"
      end

      options.join(" ")
    end
  end
end

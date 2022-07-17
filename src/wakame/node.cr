module Wakame
  # Wrapper for the `Wakame::Lib::MeCabNodeT` structure holding the parsed node.
  #
  # Access to any missing attributes will be forwarded to the underlying `Wakame::Lib::MeCabNodeT`.
  # For example, if you want to get the `id` of the node, you can do so by simply trying to access
  # its member as you normally do with typical objects:
  # ```
  # node = MeCabNode.new(node_ptr)
  # node.id # => 91
  # ```
  # For the available attributes, see the documentation of `Wakame::Lib::MeCabNodeT`.
  struct MeCabNode
    macro define_stat_method(*names)
      {% for name in names %}
        def is_{{name.id}}?
          stat == LibMeCab::{{name.id.capitalize}}Node
        end
      {% end %}
    end

    getter surface, feature
    forward_missing_to @pointer.value
    define_stat_method nor, unk, box, eos, eon

    def is_best?
      isbest == 1
    end

    def initialize(@pointer : Lib::MeCabNodeT*)
      value = @pointer.value
      @surface = String.new(Slice.new(value.surface, value.length))
      @feature = String.new(value.feature)
    end
  end

  module Lib
    # Underlying structure for `Wakame::MeCabNode`. Represents `struct mecab_node_t` in C.
    #
    # All of these attributes can be accessed directly from `Wakame::MeCabNode` without
    # retrieving this struct from its pointer. DO NOT use this struct in your actual code!
    @[Extern]
    struct MeCabNodeT
      # pointer to the previous node.
      getter prev : MeCabNodeT*
      # pointer to the next node.
      getter next : MeCabNodeT*
      # pointer to the node which ends at the same position.
      getter enext : MeCabNodeT*
      # pointer to the node which starts at the same position.
      getter bnext : MeCabNodeT*
      # pointer to the right path.
      # this value is NULL if MECAB_ONE_BEST mode.
      getter rpath : MeCabPathT*
      # pointer to the right path.
      # this value is NULL if MECAB_ONE_BEST mode.
      getter lpath : MeCabPathT*
      # surface string.
      # this value is not 0 terminated.
      # You can get the length with length/rlength members.
      getter surface : LibC::Char*
      # feature string
      getter feature : LibC::Char*
      # unique node id
      getter id : LibC::UInt
      # length of the surface form.
      getter length : LibC::UShort
      # length of the surface form including white space before the morph.
      getter rlength : LibC::UShort
      # right attribute id
      getter rc_attr : LibC::UShort
      # left attribute id
      getter lc_attr : LibC::UShort
      # unique part of speech id. This value is defined in "pos.def" file.
      getter posid : LibC::UShort
      # character type
      getter char_type : UInt8
      # status of this model.
      # This value is MECAB_NOR_NODE, MECAB_UNK_NODE, MECAB_BOS_NODE, MECAB_EOS_NODE, or MECAB_EON_NODE.
      getter stat : UInt8
      # set 1 if this node is best node.
      getter isbest : UInt8
      # forward accumulative log summation.
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter alpha : LibC::Float
      # backward accumulative log summation.
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter beta : LibC::Float
      # marginal probability.
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter prob : LibC::Float
      # word cost.
      getter wcost : LibC::Short
      # best accumulative cost from bos node to this node.
      getter cost : LibC::Long

      # :nodoc:
      def initialize(@prev, @next, @enext, @bnext, @rpath, @lpath,
                     @surface, @feature, @id, @length, @rlength, @rc_attr,
                     @lc_attr, @posid, @char_type, @stat, @isbest, @alpha,
                     @beta, @prob, @wcost, @cost)
      end
    end
  end
end

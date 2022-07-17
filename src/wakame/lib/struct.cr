module Wakame
  module Lib
    @[Extern]
    struct DictionaryInfoT
      # filename of dictionary
      # On Windows, filename is stored in UTF-8 encoding
      getter filename : LibC::Char*
      # character set of the dictionary. e.g., "SHIFT-JIS", "UTF-8"
      getter charset : LibC::Char*
      # How many words are registered in this dictionary.
      getter size : LibC::UInt
      # dictionary type
      # this value should be MECAB_USR_DIC, MECAB_SYS_DIC, or MECAB_UNK_DIC.
      getter type : LibC::Int
      # left attributes size
      getter lsize : LibC::UInt
      # right attributes size
      getter rsize : LibC::UInt
      # version of this dictionary
      getter version : LibC::UShort
      # pointer to the next dictionary info.
      getter next : DictionaryInfoT*

      # :nodoc:
      def initialize(@filename, @charset, @size, @type, @lsize, @rsize,
                     @version, @next)
      end
    end

    @[Extern]
    struct MeCabPathT
      # pointer to the right node
      getter rnode : MeCabNodeT*
      # pointer to the next right path
      getter rnext : MeCabPathT*
      # pointer to the left node
      getter lnode : MeCabNodeT*
      # pointer to the next left path
      getter lnext : MeCabPathT*
      # local cost
      getter cost : LibC::Int
      # marginal probability
      getter prob : LibC::Float

      # :nodoc:
      def initialize(@rnode, @rnext, @lnode, @lnext, @cost, @prob)
      end
    end

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

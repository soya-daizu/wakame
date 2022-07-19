module Wakame
  module Lib
    @[Extern]
    struct DictionaryInfoT
      # Filename of the dictionary.
      getter filename : LibC::Char*
      # Character set of the dictionary.
      getter charset : LibC::Char*
      # Number of words registered in the dictionary.
      getter size : UInt32
      # Dictionary type
      # This can be either MECAB_USR_DIC, MECAB_SYS_DIC, or MECAB_UNK_DIC.
      getter type : Int32
      # Left attributes size
      getter lsize : UInt32
      # Right attributes size
      getter rsize : UInt32
      # Version of this dictionary.
      getter version : UInt16
      # Pointer to the next dictionary info.
      getter next : Wakame::Lib::DictionaryInfoT*

      # :nodoc:
      def initialize(@filename, @charset, @size, @type, @lsize, @rsize,
                     @version, @next)
      end
    end

    @[Extern]
    struct MeCabPathT
      # Pointer to the right node.
      getter rnode : Wakame::Lib::MeCabNodeT*
      # Pointer to the next right path.
      getter rnext : Wakame::Lib::MeCabPathT*
      # Pointer to the left node.
      getter lnode : Wakame::Lib::MeCabNodeT*
      # Pointer to the next left path.
      getter lnext : Wakame::Lib::MeCabPathT*
      # Local cost
      getter cost : Int32
      # Marginal probability
      getter prob : Float32

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
      # Pointer to the previous node.
      getter prev : Wakame::Lib::MeCabNodeT*
      # Pointer to the next node.
      getter next : Wakame::Lib::MeCabNodeT*
      # Pointer to the node which ends at the same position.
      getter enext : Wakame::Lib::MeCabNodeT*
      # Pointer to the node which starts at the same position.
      getter bnext : Wakame::Lib::MeCabNodeT*
      # Pointer to the right path.
      # This value is NULL in MECAB_ONE_BEST mode.
      getter rpath : Wakame::Lib::MeCabPathT*
      # Pointer to the right path.
      # This value is NULL in MECAB_ONE_BEST mode.
      getter lpath : Wakame::Lib::MeCabPathT*
      # Surface string
      # This value is not 0 terminated.
      # You can get the length from the length/rlength members.
      getter surface : LibC::Char*
      # Feature string
      getter feature : LibC::Char*
      # Unique node id
      getter id : UInt32
      # Length of the surface form.
      getter length : UInt16
      # Length of the surface form including the white space before the morph.
      getter rlength : UInt16
      # Right attribute id
      getter rc_attr : UInt16
      # Left attribute id
      getter lc_attr : UInt16
      # Unique part of speech id.
      # This value is defined in "pos.def" file.
      getter posid : UInt16
      # Character type
      getter char_type : UInt8
      # Status of this model.
      # This can be either MECAB_NOR_NODE, MECAB_UNK_NODE, MECAB_BOS_NODE, MECAB_EOS_NODE, or MECAB_EON_NODE.
      getter stat : UInt8
      # Set 1 if this node is the best node.
      getter isbest : UInt8
      # Forward accumulative log summation.
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter alpha : Float32
      # Backward accumulative log summation.
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter beta : Float32
      # Marginal probability
      # This value is only available when MECAB_MARGINAL_PROB is passed.
      getter prob : Float32
      # Word cost
      getter wcost : Int16
      # Best accumulative cost from bos node to this node.
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

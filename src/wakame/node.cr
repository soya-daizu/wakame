require "./lib/*"
require "./wrapping_struct"

module Wakame
  # Wrapper for the `Wakame::Lib::MeCabNodeT` structure holding attributes
  # of the parsed node.
  struct MeCabNode
    include WrappingStruct

    enum NodeStatus
      NormalNode  = LibMeCab::NorNode
      UnknownNode = LibMeCab::UnkNode
      BosNode     = LibMeCab::BosNode
      EosNode     = LibMeCab::EosNode
      EonNode     = LibMeCab::EonNode
    end

    # Pointer to the underlying structure.
    getter pointer
    # Surface string
    getter surface
    # Feature string
    getter feature
    # Status of this model.
    getter stat
    # Formatted variant of this node.
    # The format can be specified with the options `output_format_type` or
    # `node_format` when instantiating the `Wakame::MeCab` class.
    getter formatted
    resolve_pointers(
      prev, "next", enext, bnext,
      of: Lib::MeCabNodeT, as: MeCabNode
    )
    resolve_pointers(
      rpath, lpath,
      of: Lib::MeCabPathT, as: MeCabPath
    )
    delegate_getters(
      id, length, rlength, rc_attr, lc_attr, posid,
      char_type, alpha, beta, prob, wcost, cost,
      to: Lib::MeCabNodeT
    )
    enum_methods NodeStatus, stat

    def is_best? : Bool
      @pointer.value.isbest == 1
    end

    def initialize(@pointer : Lib::MeCabNodeT*, @tagger : LibMeCab::T*? = nil)
      value = @pointer.value
      @surface = String.new(Slice.new(value.surface, value.length))
      @feature = String.new(value.feature)
      @stat = NodeStatus.new(value.stat)
      if tagger = @tagger
        @formatted = String.new(LibMeCab.format_node(tagger, @pointer))
      else
        @formatted = ""
      end
    end
  end
end

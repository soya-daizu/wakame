require "./lib/*"
require "./wrapping_struct"

module Wakame
  # Wrapper for the `Wakame::Lib::MeCabNodeT` structure holding attributes of the parsed node.
  struct MeCabNode
    include WrappingStruct

    enum Stat
      NormalNode  = LibMeCab::NorNode
      UnknownNode = LibMeCab::UnkNode
      BosNode     = LibMeCab::BosNode
      EosNode     = LibMeCab::EosNode
      EonNode     = LibMeCab::EonNode
    end

    getter surface, feature, stat, formatted
    delegate_getters(
      prev, "next", enext, bnext, rpath, lpath,
      id, length, rlength, rc_attr, lc_attr, posid,
      char_type, alpha, beta, prob, wcost, cost,
      to: Lib::MeCabNodeT
    )
    enum_methods Stat, stat

    def is_best? : Bool
      @pointer.value.isbest == 1
    end

    def initialize(@pointer : Lib::MeCabNodeT*, formatted : LibC::Char*)
      value = @pointer.value
      @surface = String.new(Slice.new(value.surface, value.length))
      @feature = String.new(value.feature)
      @stat = Stat.new(value.stat)
      @formatted = String.new(formatted)
    end
  end
end

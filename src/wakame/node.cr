require "./lib/*"
require "./wrapping_struct"

module Wakame
  # Wrapper for the `Wakame::Lib::MeCabNodeT` structure holding attributes of the parsed node.
  struct MeCabNode
    include WrappingStruct

    enum Stat
      NorNode = LibMeCab::NorNode
      UnkNode = LibMeCab::UnkNode
      BosNode = LibMeCab::BosNode
      EosNode = LibMeCab::EosNode
      EonNode = LibMeCab::EonNode
    end

    getter surface, feature
    delegate_getters(
      prev, "next", enext, bnext, rpath, lpath,
      id, length, rlength, rc_attr, lc_attr, posid,
      char_type, alpha, beta, prob, wcost, cost,
      to: Lib::MeCabNodeT
    )
    enum_methods(
      nor_node?, unkr_node?, bosr_node?,
      eosr_node?, eonr_node?,
      of: stat
    )

    def stat : Stat
      Stat.new(@pointer.value.stat)
    end

    def is_best? : Bool
      @pointer.value.isbest == 1
    end

    def initialize(@pointer : Lib::MeCabNodeT*)
      value = @pointer.value
      @surface = String.new(Slice.new(value.surface, value.length))
      @feature = String.new(value.feature)
    end
  end
end

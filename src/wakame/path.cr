require "./lib/*"
require "./wrapping_struct"

module Wakame
  # Wrapper for the `Wakame::Lib::MeCabNodeT` structure.
  struct MeCabPath
    include WrappingStruct

    # Pointer to the underlying structure.
    getter pointer
    resolve_pointers(
      rnode, lnode,
      of: Lib::MeCabNodeT, as: MeCabNode
    )
    resolve_pointers(
      rnext, lnext,
      of: Lib::MeCabPathT, as: MeCabPath
    )
    delegate_getters(
      cost, prob,
      to: Lib::MeCabPathT
    )

    def initialize(@pointer : Lib::MeCabPathT*)
    end
  end
end

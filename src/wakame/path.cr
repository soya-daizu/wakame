module Wakame
  module Lib
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
  end
end

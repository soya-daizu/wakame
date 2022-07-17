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
end

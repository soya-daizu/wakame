module Wakame
  struct DictionaryInfo
    macro define_type_method(*names)
      {% for name in names %}
        def is_{{name.id}}dic?
          type == LibMeCab::{{name.id.capitalize}}Dic
        end
      {% end %}
    end

    getter filename, charset
    forward_missing_to @pointer.value
    define_type_method usr, sys, unk

    def initialize(@pointer : Lib::DictionaryInfoT*)
      value = @pointer.value
      @filename = String.new(value.filename)
      @charset = String.new(value.charset)
    end
  end
end

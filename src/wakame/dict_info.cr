module Wakame
  struct DictionaryInfo
    macro define_type_method(*names)
      {% for name in names %}
        def is_{{name.id}}dic?
          type == LibMeCab::{{name.id.capitalize}}Dic
        end
      {% end %}
    end

    forward_missing_to @pointer.value
    define_type_method usr, sys, unk
    getter filename, charset

    def initialize(@pointer : Lib::DictionaryInfoT*)
      value = @pointer.value
      @filename = String.new(value.filename)
      @charset = String.new(value.charset)
    end
  end

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
  end
end

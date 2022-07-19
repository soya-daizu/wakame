require "./lib/*"
require "./wrapping_struct"

module Wakame
  struct DictionaryInfo
    include WrappingStruct

    enum DictionaryType
      SystemDic  = LibMeCab::SysDic
      UserDic    = LibMeCab::UsrDic
      UnknownDic = LibMeCab::UnkDic
    end

    # Pointer to the underlying structure.
    getter pointer
    # Filename of the dictionary.
    getter filename
    # Character set of the dictionary.
    getter charset
    # Dictionary type.
    getter type
    delegate_getters(
      size, lsize, rsize, version, "next",
      to: Lib::DictionaryInfoT
    )
    enum_methods DictionaryType, type

    def initialize(@pointer : Lib::DictionaryInfoT*)
      value = @pointer.value
      @filename = String.new(value.filename)
      @charset = String.new(value.charset)
      @type = DictionaryType.new(value.type)
    end
  end
end

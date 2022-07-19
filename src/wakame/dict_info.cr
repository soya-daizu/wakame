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

    getter filename, charset, type
    delegate_getters(
      size, lsize, rsize, version, "next",
      to: Lib::DictionaryInfoT
    )
    enum_methods DictionaryType, type

    def initialize(@pointer : Lib::DictionaryInfoT*)
      value = @pointer.value
      @filename = String.new(value.filename)
      @charset = String.new(value.charset)
      @type = Type.new(value.type)
    end
  end
end

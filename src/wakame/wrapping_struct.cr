module Wakame
  module WrappingStruct
    macro delegate_getters(*names, to base_type)
      {% base_methods = base_type.resolve.methods %}
      {% for name in names %}
        {% return_type = base_methods.find { |m| m.name == name.id }.return_type %}
        def {{name.id}} : {{return_type}}
          @pointer.value.{{name.id}}
        end
      {% end %}
    end

    macro enum_methods(*names, of dest)
      {% for name in names %}
        def {{name.id}} : Bool
          {{dest.id}}.{{name.id}}
        end
      {% end %}
    end
  end
end

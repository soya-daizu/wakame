module Wakame
  module WrappingStruct
    private macro delegate_getters(*names, to base_type)
      {% base_methods = base_type.resolve.methods %}
      {% for name in names %}
        {% return_type = base_methods.find { |m| m.name == name.id }.return_type %}
        # This method forwards the call to the underlying `{{base_type.resolve}}` structure.
        #
        # See `{{base_type.resolve}}#{{name.id}}` for details.
        def {{name.id}} : {{return_type}}
          @pointer.value.{{name.id}}
        end
      {% end %}
    end

    private macro enum_methods(enum_type, target)
      {% constants = enum_type.resolve.constants %}
      {% for constant in constants %}
        {% underscored = constant.stringify.underscore.id %}
        # Calls `{{enum_type}}#{{underscored}}?` of the `#{{target.id}}`.
        def {{underscored}}? : Bool
          {{target.id}}.{{underscored}}?
        end
      {% end %}
    end
  end
end

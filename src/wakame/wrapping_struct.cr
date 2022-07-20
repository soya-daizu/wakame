module Wakame
  # Internal module which is shared across the wrapper structs.
  module WrappingStruct
    private macro resolve_pointers(*names, of base_type, as dest_type)
      {% for name in names %}
        # This method forwards the call to the underlying `{{base_type.resolve}}` structure,
        # resolves the pointer returned, and returns the wrapped variant of it.
        #
        # See `{{base_type.resolve}}#{{name.id}}` for details on the underlying value.
        def {{name.id}} : {{dest_type}}?
          pointer = @pointer.value.{{name.id}}
          {% if dest_type.stringify == "MeCabNode" %}
            {{dest_type}}.new(pointer, @tagger) if pointer
          {% else %}
            {{dest_type}}.new(pointer) if pointer
          {% end %}
        end
      {% end %}
    end

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

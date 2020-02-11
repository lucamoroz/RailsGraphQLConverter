module Components
  class ScalarComponent
    ENUM_SUFFIX = "Types::Enums::"

    attr_reader :model, :column

    def initialize(model, column)
      @model = model
      @column = column
    end

    def name
      column.name
    end

    def type
      if self.enum?
        return ENUM_SUFFIX + column.name.singularize.camelize
      elsif name == "id"
        return "ID"
      end

      # all types: https://guides.rubyonrails.org/v3.2/migrations.html#supported-types
      case column.type.to_sym
      when :integer
          "Int"
      when :boolean
        "Boolean"
      when :float
        "Float"
      when :string
        "String"
      when :text
        "String"
      when :datetime
        # ISO8601DateTime added year 2018
        "GraphQL::Types::ISO8601DateTime"
      else
        "# not implemented: #{column.type}, for attr: #{column.name}"
      end
    end

    def to_s
      raise NotImplementedError
    end

    protected

    def enum?
      candidate = column.name.pluralize
      model.respond_to?(candidate) && model.send(candidate).class == ActiveSupport::HashWithIndifferentAccess
    end
  end
end

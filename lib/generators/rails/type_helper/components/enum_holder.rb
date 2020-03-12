module Components
  class EnumHolder
    attr_reader :model, :column

    def initialize(model, column)
      @model = model
      @column = column

      unless EnumHolder.enum? model, column
        raise ArgumentError("Invalid column: not enum")
      end
    end

    def name
      column.name
    end

    def enum_values
      model.send(column.name.pluralize).map do |k, v|
        "value :#{k}"
      end
    end

    def self.enum?(model, column)
      candidate = column.name.pluralize
      model.respond_to?(candidate) && model.send(candidate).class == ActiveSupport::HashWithIndifferentAccess
    end

  end
end


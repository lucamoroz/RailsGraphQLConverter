module Components
  class TypeComponent
    TYPE_SUFFIX = "Type"

    attr_reader :model, :association
    
    def initialize(model, association)
      @association = association
      @model = model
    end

    def name
      association.name.to_s
    end

    def type
      class_name = association.options[:class_name] || name.singularize.camelize
      field_type = class_name + TYPE_SUFFIX
      field_type = "[#{field_type}]" if array? association
      field_type
    end

    def to_s
      raise NotImplementedError
    end

    def dependency
      relation_name = association.name.to_s
      class_name = association.options[:class_name] || relation_name.singularize.camelize
      return class_name
    end

    protected

    def array?(association)
      macro = association.macro
      macro == :has_and_belongs_to_many || macro == :has_many
    end
  end
end

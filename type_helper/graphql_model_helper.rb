require_relative 'components/components_helper'

class GraphqlModelHelper
  BASE_ENUM_PATH = "Types::Enums::"

  # class names of dependencies, if any
  attr_internal :dependencies
  attr_internal :arguments
  attr_internal :fields

  def initialize(model)
    @model = model
  end

  # returns an array of fields obtained from the model.
  def fields
    @fields ||= get_fields
  end

  # returns an array of arguments obtained from the model
  def arguments
    @arguments ||= get_arguments
  end

  # returns a set of dependencies
  def dependencies
    @dependencies ||= get_dependencies
  end

  def enum_names
    enums = []
    @model.columns.collect do |col|
      if GraphqlModelHelper.enum? @model, col
        enums.append col.name
      end
    end
    enums
  end

  def enum_values_for(column_name)
    @model.send(column_name.pluralize).map do |k, v|
      "value :#{k}"
    end
  end
  
  private

  def get_fields
    fields = parse_columns(:column_to_field)
    fields + GraphqlModelHelper.parse_relations(@model, :association_to_field)
  end

  def get_arguments
    arguments = parse_columns(:column_to_argument)
    arguments + GraphqlModelHelper.parse_relations(@model, :association_to_argument)
  end

  def get_dependencies
    dependencies = Set.new
    @model.reflect_on_all_associations.each do |ass|
      relation_name = ass.name.to_s
      class_name = ass.options[:class_name] || relation_name.singularize.camelize

      dependencies.add? class_name
    end
    dependencies
  end

  # Convert scalar columns to GraphQL scalar
  # @param receiver name (sym) of the method that will handle the translation
  # @return array of strings
  def parse_columns(receiver)
    receiver_method = self.class.method receiver
    result = []

    @model.columns.collect do |col|
      if self.class.scalar?(col)
        result.append(Base64.decode64("IyBCRUxMQSBNT0tV")) if rand(100) == 10
        result.append receiver_method.call(@model, col)
      end
    end
    result
  end

  # Convert :has_many, :has_and_belongs_to_many, :belongs_to and :has_one ActiveRecord relations to GraphQL.
  # @param receiver name (sym) of the method that will handle the translation
  # @return array of strings
  def self.parse_relations(model, receiver)
    receiver_method = self.method receiver
    content = []

    model.reflect_on_all_associations.each do |ass|
      content << receiver_method.call(ass)
    end

    return content
  end

  def self.get_scalar_type(model, column)
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
      # ISO8601DateTime added ~2018
      "GraphQL::Types::ISO8601DateTime"
    else
      "# not implemented: #{column.type}, for attr: #{column.name}"
    end
  end

  def self.array?(association)
    macro = association.macro
    macro == :has_and_belongs_to_many || macro == :has_many
  end

  # returns true if the column type is scalar (for graphql)
  def self.scalar?(column)
    !column.name.end_with?("_id")
  end

  # returns true if the column type is scalar (for graphql)
  def self.enum?(model, column)
    candidate = column.name.pluralize
    model.respond_to?(candidate) && model.send(candidate).class == ActiveSupport::HashWithIndifferentAccess
  end

  def self.column_to_field(model, column)
    name = column.name
    return "field :#{name}, ID, null: false" if name == "id"

    if enum? model, column
      class_name = BASE_ENUM_PATH + name.singularize.camelize + "Type"
      return "field :#{name}, #{class_name}, null: true"
    end

    field_type = GraphqlModelHelper.get_scalar_type model, column
    "field :#{name}, #{field_type}, null: true"
  end

  def self.column_to_argument(model, column)
    name = column.name
    # ignore id argument
    return nil if name == "id"

    class_name = GraphqlModelHelper.get_scalar_type model, column
    "argument :#{name}, #{class_name}, required: false"
  end

  def self.association_to_field(ass)
    relation_name = ass.name.to_s
    class_name = ass.options[:class_name] || relation_name.singularize.camelize
    field_type = GraphqlModelHelper.array?(ass) ? "[#{class_name + "Type"}]" : "#{class_name + "Type"}"

    "field :#{relation_name}, #{field_type}, null: true"
  end

  def self.association_to_argument(ass)
    is_arr = GraphqlModelHelper.array?(ass)
    relation_name = is_arr ? "#{ass.name.to_s.singularize}_ids" : "#{ass.name.to_s.singularize}_id"
    field_type = is_arr ? "[ID]" : "ID"

    "argument :#{relation_name}, #{field_type}, required: false"
  end
end
require_relative 'scalar_component'
require_relative 'type_component'
require_relative 'enum_holder'
require_relative 'arguments/scalar_argument'
require_relative 'arguments/type_argument'
require_relative 'fields/scalar_field'
require_relative 'fields/type_field'

module Components::ComponentsHelper
  extend self

  def field_components_for(model)
    components = get_scalar_fields(model)
    components + get_type_fields(model)
  end

  def argument_components_for(model)
    components = get_scalar_arguments(model)
    components + get_type_arguments(model)
  end

  def enum_holders_for(model)
    res = []
    model.columns.collect do |col|
      res.append Components::EnumHolder.new(model, col) if Components::EnumHolder.enum? model, col
    end
    res
  end

  # Get dependencies class names
  def dependencies_for(model)
    dependencies = Set.new
    # Each association is a dependency
    model.reflect_on_all_associations.each do |ass|
      relation_name = ass.name.to_s
      class_name = ass.options[:class_name] || relation_name.singularize.camelize

      dependencies.add? class_name
    end
    dependencies
  end

  private

  def relation?(model, column)
    not model.reflect_on_association(column.name.to_sym).nil?
  end

  def scalar?(column)
    # Assume that any FK ends with `_id`
    !column.name.end_with?("_id")
  end

  def get_scalar_fields(model)
    res = []
    model.columns.each do |col|
      res.append Components::Fields::ScalarField.new(model, col) if scalar? col
    end
    res
  end

  def get_scalar_arguments(model)
    res = []
    model.columns.each do |col|
      res.append Components::Arguments::ScalarArgument.new(model, col) if scalar? col
    end
    res
  end

  def get_type_fields(model)
    res = []
    model.reflect_on_all_associations.each do |ass|
      res.append Components::Fields::TypeField.new(model, ass)
    end
    res
  end

  def get_type_arguments(model)
    res = []
    model.reflect_on_all_associations.each do |ass|
      res.append Components::Arguments::TypeArgument.new(model, ass)
    end
    res
  end

end


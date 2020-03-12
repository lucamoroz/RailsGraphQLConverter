require_relative 'components/components_helper'

class Rails::TypeHelperGenerator < Rails::Generators::NamedBase
  # The methods defined here are executed sequentially

  source_root File.expand_path('templates', __dir__)

  class_option :no_type, type: :boolean, default: false, desc: "Skip types generation"
  class_option :no_enums, type: :boolean, default: false, desc: "Skip enums generation"
  class_option :no_input, type: :boolean, default: false, desc: "Skip input generation"
  class_option :no_mutations, type: :boolean, default: false, desc: "Skip mutations generation"
  class_option :no_dependencies, type: :boolean, default: false, desc: "Skip dependencies generation"

  BASE_TYPE_PATH = "app/graphql/types/base/"

  def get_model
    @model = class_name.singularize.classify.constantize
    @model.connection
    @model
  rescue NameError
    if yes?("Model implementation for class: '#{class_name}' not found! Generate empty type anyway?")
      create_type_file
      exit
    else
      exit 0
    end
  end

  def create_type_file
    return if options["no_type"]

    @rows = Components::ComponentsHelper.field_components_for(@model).map(&:to_s)
    template "type_template.erb", "app/graphql/types/#{file_name}_type.rb"
  end

  def create_enum_files
    return if options["no_enums"]

    Components::ComponentsHelper.enum_holders_for(@model).each do |enum_h|
      @enum_name = enum_h.name
      @rows = enum_h.enum_values
      template "enum_template.erb", "app/graphql/types/enums/#{@enum_name}_enum.rb"
    end
  end

  def create_input_file
    return if options["no_input"]

    @rows = Components::ComponentsHelper.argument_components_for(@model).map(&:to_s)
    template "input_template.erb", "app/graphql/inputs/#{file_name}_input.rb"
  end

  def create_create_create_mutation_file
    return if options["no_mutations"]

    template "mutation_create_template.erb", "app/graphql/mutations/#{file_name}_mutations/#{file_name}_create.rb"
  end

  def create_update_mutation_file
    return if options["no_mutations"]

    template "mutation_update_template.erb", "app/graphql/mutations/#{file_name}_mutations/#{file_name}_update.rb"
  end

  def create_delete_mutation_file
    return if options["no_mutations"]

    template "mutation_delete_template.erb", "app/graphql/mutations/#{file_name}_mutations/#{file_name}_delete.rb"
  end

  def get_dependencies
    @dependencies = Components::ComponentsHelper.dependencies_for(@model)
    puts "\nFound dependencies: #{@dependencies}"
  end

  def generate_dependencies
    return if options["no_dependencies"]

    @dependencies.each do |dependency|
      d_file_name = dependency.tableize.singularize
      # check type
      missing_type = !File.exist?("app/graphql/types/#{d_file_name}_type.rb")
      # check input
      missing_input = !File.exists?("app/graphql/types/inputs/#{d_file_name}_input.rb")
      # check mutations
      missing_mutations = !File.exist?("app/graphql/mutations/#{d_file_name}_mutations/#{d_file_name}_create.rb") \
         || !File.exist?("app/graphql/mutations/#{d_file_name}_mutations/#{d_file_name}_update.rb") \
         || !File.exist?("app/graphql/mutations/#{d_file_name}_mutations/#{d_file_name}_delete.rb")

      if missing_type || missing_input || missing_mutations
        if yes?("Found unresolved dependency for: #{dependency}. Do you want to generate it?")
          args = dependency.to_s + @options.map{ |k, v| " --#{k.to_s} #{v.to_s}" }.join
          generate :type_helper, args
        end
      else
        puts "Mutations dependency '#{dependency}' already satisfied. Run 'rails generate type_helper #{dependency}' to overwrite it."
      end
    end
  end

  def check_operations_return_type
    return if options["no_mutations"] or options["no_dependencies"]

    unless File.exist?("app/graphql/types/operation_return_type.rb")
      if yes? "The generated delete mutations are based on the class OperationReturnType and it seems you don't have it in your project. Do you want to generate it?"
        copy_file "dependencies/operation_return_type.rb", "app/graphql/types/operation_return_type.rb"
      end
    end
  end

  def check_base_mutation_dependencies
    return if options["no_mutations"] or options["no_dependencies"]

    unless File.exist?("app/graphql/mutations/base/base_mutation.rb")
      if yes? "The generated delete mutations are based on the class BaseMutation and it seems you don't have it in your project. Do you want to generate it?"
        copy_file "dependencies/base_mutation.rb", "app/graphql/mutations/base/base_mutation.rb"
      end
    end
  end

  def check_base_type_dependencies
    return if options["no_dependencies"]

    base_dependencies = %w(base_argument.rb base_enum.rb base_field.rb base_input_object.rb base_object.rb)

    base_dependencies.each do |dep|
      unless File.exist?(BASE_TYPE_PATH + dep)
        if yes? "The generated delete mutations are based on #{dep} and it seems you don't have it in your project. Do you want to generate it?"
          copy_file "dependencies/" + dep, BASE_TYPE_PATH + dep
        end
      end
    end

  end
end

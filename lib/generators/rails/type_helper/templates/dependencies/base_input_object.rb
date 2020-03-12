module Types
  module Base
    class BaseInputObject < GraphQL::Schema::InputObject
      argument_class Types::Base::BaseArgument
    end
  end
end

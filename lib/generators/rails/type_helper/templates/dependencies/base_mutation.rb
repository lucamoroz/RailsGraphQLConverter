module Mutations
  module Base
    class BaseMutation < GraphQL::Schema::Mutation

      argument_class Types::Base::BaseArgument
      field_class Types::Base::BaseField
      object_class Types::Base::BaseObject

      null false
    end
  end
end

module Components
  module Arguments
    class ScalarArgument < ScalarComponent
      def to_s
        # IDs are excluded from the arguments
        return "" if name == "id"

        # we can't know if an argument is mandatory
        "argument :#{name}, #{type}, required: false"
      end

    end
  end
end

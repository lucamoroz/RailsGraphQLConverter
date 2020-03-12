module Components
  module Arguments
    class TypeArgument < TypeComponent
      def to_s
        "argument :#{name}, #{type}, required: false"
      end
    end
  end
end


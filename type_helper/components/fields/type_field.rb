module Components
  module Fields
    class TypeField < TypeComponent
      def to_s
        "field :#{name}, #{type}, null: true"
      end
    end
  end
end

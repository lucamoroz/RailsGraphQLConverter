module Components
  module Fields
    class ScalarField < ScalarComponent
      def to_s
        if name == "id"
          "field :#{name}, #{type}, null: false"
        else
          "field :#{name}, #{type}, null: true"
        end
      end
    end
  end
end

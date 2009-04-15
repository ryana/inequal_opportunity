module ActiveRecord

  module Inequality

    class Base
      attr_accessor :value
  
      def initialize(val)
        self.value = val
      end

    end

    class GreaterThanEqual < Base
    end


    module WrapperMethods

      def gte(val)
        GreaterThanEqual.new(val)
      end

    end

  end
end

ActiveRecord::Base.send :include, ActiveRecord::Inequality::WrapperMethods
ActiveRecord::Base.extend ActiveRecord::Inequality::WrapperMethods

module ActiveRecord
  module Inequality

    class InequalError < Exception
    end

    class Base
      attr_accessor :value
  
      def initialize(val)
        self.value = val
      end

      def operator
        raise('Nope')
      end

      def ==(val)
        self.operator == val.operator && self.value == val.value
      end
    
      def string_value
        value ? "'#{value}'" : 'nil'
      end

      def inspect
        " #{operator} #{self.string_value}"
      end

    end

    class GreaterThanEqual < Base
      def operator
        '>='
      end
    end

    class GreaterThan < Base
      def operator
        '>'
      end
    end

    class LessThanEqual < Base
      def operator
        '<='
      end
    end

    class LessThan < Base
      def operator
        '<'
      end
    end

    class NotEqual < Base
      def operator
        if value.nil?
         'IS NOT'
        elsif value.is_a? Array
         'NOT IN'
        else
          '<>'
        end
      end
    end

    class Like < Base
      def operator
        'LIKE'
      end
 
      # This method is why I love Ruby
      def value(override = false)
        v = super(*[])

        if !override && !v.is_a?(Numeric) && !v.is_a?(String)
          raise InequalError, "Passing #{v.class} to Like.  You can't possibly want to do this"
        end

        "%#{v}%"
      end
    end

    module WrapperMethods

      def lte(val)
        ActiveRecord::Inequality::LessThanEqual.new(val)
      end

      def lt(val)
        ActiveRecord::Inequality::LessThan.new(val)
      end

      def gte(val)
        ActiveRecord::Inequality::GreaterThanEqual.new(val)
      end

      def gt(val)
        ActiveRecord::Inequality::GreaterThan.new(val)
      end

      def ne(val)
        ActiveRecord::Inequality::NotEqual.new(val)
      end

      def like(val)
        ActiveRecord::Inequality::Like.new(val)
      end

    end

  end

  class Base
    class << self
      alias attribute_condition_orig attribute_condition
      def attribute_condition(quoted_column_name, argument)
        if argument.is_a? ActiveRecord::Inequality::Base
          question = argument.value.is_a?(Array) ? '(?)' : '?'
          "#{quoted_column_name} #{argument.operator} #{question}"
        else
          attribute_condition_orig(quoted_column_name, argument)
        end
      end

      # Copied this from AR.  Not ideal.
      alias expand_range_bind_variables_orig expand_range_bind_variables
      def expand_range_bind_variables(bind_vars)
        expanded = []

        bind_vars.each do |var|
          next if var.is_a?(Hash)

          if var.is_a?(Range)
            expanded << var.first
            expanded << var.last
          elsif var.is_a?(ActiveRecord::Inequality::Base)
            expanded << var.value
          else
            expanded << var
          end
        end

        expanded
      end

    end
  end

end

include ActiveRecord::Inequality::WrapperMethods


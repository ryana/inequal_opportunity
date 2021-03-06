require File.join(File.dirname(__FILE__), 'test_helper')
require File.join(File.dirname(__FILE__), 'db_setup')

METHOD_SYMBOLS = [:gt, :gte, :lt, :lte, :ne, :like]

class Main < ActiveRecord::Base
  belongs_to :seconds
  named_scope :newer_than, lambda {|time| {:conditions => {:created_at => gte(time) }} }

  METHOD_SYMBOLS.each do |s|
    named_scope :"try_#{s}", lambda {|i| {:conditions => {:id => send(s, i)}} }
  end

end

class Second < ActiveRecord::Base
  has_many :mains
end

class InequalOpportunityTest < Test::Unit::TestCase

  def setup
    TABLES.each do |t|
      ActiveRecord::Base.connection.execute("DELETE FROM #{t};")
    end
 end

  context "a model" do
    setup do
      @model = Main
    end

    should "respond to gte" do
      assert @model.respond_to?(:gte)
    end

    should "should work with a named_scope" do
      assert_equal Main.newer_than(2.days.ago).all, []
    end

    should "generate proper sql for array" do
      METHOD_SYMBOLS.each do |s|

        if s == :ne
          assert_equal Main.try_ne([1,2,3]).first, nil
        elsif s == :like
          assert_raises ActiveRecord::Inequality::InequalError do
            assert_equal Main.try_like([1,2,3]).first, nil
          end
        else
          assert_raises ActiveRecord::StatementInvalid do
            assert_equal Main.send(:"try_#{s}", [1,2,3]).first, nil
          end
        end
      end

      assert_equal Main.try_ne([1,2,3]).first, nil
      assert_equal Main.try_ne([1,2,3]).count, 0
    end

    should "generate proper sql for nil and not nil" do
      METHOD_SYMBOLS.each do |s|
        assert_equal Main.send(:"try_#{s}", 1).first, nil
        assert_equal Main.send(:"try_#{s}", nil).first, nil unless s == :like
      end

      assert_raises ActiveRecord::Inequality::InequalError do
        Main.try_like(nil).first
      end
    end

    should "properly scope based on gte" do
      time = 2.days.ago
      num = 3
      num.times { Main.create(:val => 3) }
      num.times { Main.create(:val => 1) }

      assert_equal Main.count(:conditions => {:val => gte(2)}), num
    end

  end

  context "an instance" do
    setup do
      @main = Main.new
    end

    should "respond to gte" do
      assert @main.respond_to?(:gte)
    end

  end

  context "a parent" do
    setup do
      @second = Second.new
    end

    should "see through assocaitions" do
      assert @second.mains.respond_to?(:gte)
    end
  end

  context "Object" do
    should "have gte" do
      wrapped = gte(5)
      assert_equal wrapped.operator, '>='
      assert_equal wrapped, ActiveRecord::Inequality::GreaterThanEqual.new(5)
    end

    should "have gt" do
      wrapped = gt(5)
      assert_equal wrapped.operator, '>'
      assert_equal wrapped, ActiveRecord::Inequality::GreaterThan.new(5)
    end

    should "have lte" do
      wrapped = lte(5)
      assert_equal wrapped.operator, '<='
      assert_equal wrapped, ActiveRecord::Inequality::LessThanEqual.new(5)
    end

    should "have lt" do
      wrapped = lt(5)
      assert_equal wrapped.operator, '<'
      assert_equal wrapped, ActiveRecord::Inequality::LessThan.new(5)
    end

    should "have ne" do
      wrapped = ne(5)
      assert_equal wrapped.operator, '<>'
      assert_equal wrapped, ActiveRecord::Inequality::NotEqual.new(5)
    end

    should "have a different operator when calling ne w/ nil" do
      wrapped = ne(nil)
      assert_equal wrapped.operator, 'IS NOT'
      assert_equal wrapped, ActiveRecord::Inequality::NotEqual.new(nil)
    end

    should "have a different operator when calling ne w/ true" do
      wrapped = ne(true)
      assert_equal wrapped.operator, 'IS NOT'
      assert_equal wrapped, ActiveRecord::Inequality::NotEqual.new(true)
    end

    should "have a different operator when calling ne w/ false" do
      wrapped = ne(false)
      assert_equal wrapped.operator, 'IS NOT'
      assert_equal wrapped, ActiveRecord::Inequality::NotEqual.new(false)
    end



    should "have like" do
      wrapped = like('ryan')
      assert_equal wrapped.operator, 'LIKE'
      assert_equal wrapped, ActiveRecord::Inequality::Like.new('ryan')
    end

  end

  context "expand_range_bind_variables_orig" do
    should "return a proper array" do
      range_start = 1
      range_end = 9

      input = [{:a => 1}, (range_start..range_end), "Yo", {:c => 'd'}, 23, [1,2,3]]
      res = ActiveRecord::Base.send :expand_range_bind_variables_orig, input

      assert_equal res, [range_start, range_end, "Yo", 23, [1,2,3]]
    end
  end

end

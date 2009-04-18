require File.dirname(__FILE__) + '/test_helper'
require 'ruby-debug'

DB = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml'))).symbolize_keys!
ActiveRecord::Base.establish_connection(DB[:source])

TABLES = %w(mains seconds)

class Main < ActiveRecord::Base
  belongs_to :seconds
  named_scope :newer_than, lambda {|time| {:conditions => {:created_at => gte(time) }} }
end

class Second < ActiveRecord::Base
  has_many :mains
end

#ActiveRecord::Base.logger = Logger.new(STDOUT)

class InequalOpportunityTest < Test::Unit::TestCase

  def setup
    TABLES.each do |t|
      ActiveRecord::Base.connection.execute("create table #{t} (id integer, val integer, seconds_id integer, mains_id integer, created_at datetime default null);")
    end
  end

  def teardown
    TABLES.each do |t|
      ActiveRecord::Base.connection.execute("drop table #{t};")
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
      assert_equal Main.newer_than(2.days.ago), []
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

  end

end

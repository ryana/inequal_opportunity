require File.dirname(__FILE__) + '/test_helper'

DB = YAML::load(File.open(File.join(File.dirname(__FILE__), 'database.yml'))).symbolize_keys!
ActiveRecord::Base.establish_connection(DB[:source])

class Main < ActiveRecord::Base
end

class InequalOpportunityTest < Test::Unit::TestCase

  def setup
    ActiveRecord::Base.connection.execute('create table mains (created_at datetime default null);')
  end

  def teardown
    ActiveRecord::Base.connection.execute('drop table mains;')
  end

  context "a model" do
    setup do
      @model = Main
    end

    should "respond to gte" do
      assert @model.respond_to?(:gte)
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

end

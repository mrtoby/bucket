#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestDataObject < Test::Unit::TestCase

  include TestBucketBase

  class SomeDataObject
    def initialize
      @a_variable = :initial_value
    end

    def some_method
      :the_return_value
    end
  end

  def test_database_with_data_object_is_new
    with_new_db(SomeDataObject) do |db|
      assert_equal(true, db.just_created?)
    end
  end
 
  def test_initialized
    with_new_db(SomeDataObject) do |db|
      assert_equal(:initial_value, db.transaction { @a_variable }) 
    end
  end

  def test_variable_can_be_changed
    with_new_db(SomeDataObject) do |db|
      db.transaction { @a_variable = :changed_value }
      assert_equal(:changed_value, db.transaction { @a_variable }) 
    end
  end

  def test_call_method_in_data_object
    with_new_db(SomeDataObject) do |db|
      assert_equal(:the_return_value, db.transaction { some_method })
    end
  end
  
end

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
    db = open_new_db(SomeDataObject)
    assert_equal(true, db.is_new?)
  end
 
  def test_initialized
    db = open_new_db(SomeDataObject)
    assert_equal(:initial_value, db.transaction { @a_variable }) 
    db.close
  end

  def test_variable_can_be_changed
    db = open_new_db(SomeDataObject)
    db.transaction { @a_variable = :changed_value }
    assert_equal(:changed_value, db.transaction { @a_variable }) 
    db.close
  end

  def test_call_method_in_data_object
    db = open_new_db(SomeDataObject)
    assert_equal(:the_return_value, db.transaction { some_method })
    db.close
  end
end


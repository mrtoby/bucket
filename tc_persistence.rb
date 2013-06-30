#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestPersistence < Test::Unit::TestCase

  include TestBucketBase

  def test_value_is_persistent
    # Create database and set a variable
    with_new_empty_db do |db|
      db.transaction { @a_variable = :a_value }
      db.close

      # Open/restore database and verify that the variable is there
      db.open
      assert_equal(false, db.just_created?)
      assert_equal(:a_value, db.transaction { @a_variable })
    end
  end  

end

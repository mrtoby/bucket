#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestPersistence < Test::Unit::TestCase

  include TestBucketBase

  def test_value_is_persistent
    # Create database and set a variable
    db = open_new_empty_db
    db.transaction { @a_variable = :a_value }
    db.close

    # Open/restore database and verify that the variable is there
    db.open
    assert_equal(false, db.is_new?)
    assert_equal(:a_value, db.transaction { @a_variable })
    db.close
  end  

end


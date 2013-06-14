#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestBasics < Test::Unit::TestCase

  include TestBucketBase

  def test_database_is_new
    db = open_new_empty_db
    assert_equal(true, db.is_new?)
    db.close
  end

  def test_set_a_value
    db = open_new_empty_db
    db.transaction { @a_variable = :a_value }
    assert_equal(:a_value, db.transaction { @a_variable })
    db.close
  end

  def test_change_a_value
    db = open_new_empty_db
    db.transaction { @a_variable = :first_value }
    db.transaction { @a_variable = :second_value }
    assert_equal(:second_value, db.transaction { @a_variable })
    db.close
  end  
end


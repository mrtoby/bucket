#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestScopes < Test::Unit::TestCase

  include TestBucketBase

  def test_variable_not_set_in_caller_scope
    db = open_new_empty_db
    db.transaction { @a_variable = :a_value }
    assert_not_equal(:a_value, @a_variable)
    db.close
  end

  def test_cannot_access_variable_outside_transaction_scope
    db = open_new_empty_db
    not_in_transaction_scope = :a_value
    exception_caught = false
    begin
      db.transaction { @a_variable = not_in_transaction_scope }
    rescue
      exception_caught = true    
    end
    assert_equal(true, exception_caught)
    db.close
  end
end


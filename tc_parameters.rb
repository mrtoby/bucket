#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestParameters < Test::Unit::TestCase

  include TestBucketBase

  def test_setting_variable_using_parameter
    db = open_new_empty_db
    db.transaction(:a_value) { |v| @a_variable = v }
    assert_equal(:a_value, db.transaction { @a_variable })
    db.close
  end
end

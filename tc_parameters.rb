#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestParameters < Test::Unit::TestCase

  include TestBucketBase

  def test_setting_variable_using_parameter
    with_new_empty_db do |db|
      db.transaction(:a_value) { |v| @a_variable = v }
      assert_equal(:a_value, db.transaction { @a_variable })
    end
  end
  
end

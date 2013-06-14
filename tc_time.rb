#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base.rb'

class TestTime < Test::Unit::TestCase

  include TestBucketBase

  def test_time_is_preserved
    # Save the (controlled) time in a variable
    db = open_new_empty_db
    db.clock.pause
    db.clock.travel(-4711) # Just some time in the past
    time_in_transaction = db.transaction { @a_variable = clock.now }
    db.close

    # Re-open the database (with a new clock running at system
    # time). But the clock in the applied transaction should be preserved
    # and the variable should thus have the same value as before.
    db.open
    assert_equal(time_in_transaction, db.transaction { @a_variable })
    db.close
  end

end


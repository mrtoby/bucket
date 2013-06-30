#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'

class TestConcurrency < Test::Unit::TestCase

  include TestBucketBase

  def test_concurrent_transactions_not_possible
    skip("Don't know any good way to test this");
    mutex = Mutex.new
    with_new_empty_db do |db|
      # Create a fiber that starts a transaction and then halts, 
      # and run it until the halting point
      a_fiber = Fiber.new do
        db.transaction { Fiber.yield }
      end
      a_fiber.resume

      # Create a thread that tries to start a transaction
      a_thread = Thread.new do
        db.transaction { :just_something }
        mutex.lock
      end
      sleep(1)

      # The thread should be blocked by the transaction and the mutex
      # should thus not be locked
      assert_equal(false, mutex.locked?)

      a_fiber.resume
      sleep(1)
      assert_equal(true, mutex.locked?)

      # Cleanup
      Thread.kill(a_thread)
    end
  end
  
end

#!/usr/bin/env ruby

require 'test/unit'
require './tc_bucket_base'


class NonBlockingMutex

  def initialize()
    @mutex = Mutex.new
  end

  def lock
    if not(@mutex.try_lock)
      raise IllegalStateError.new('Mutex already locked')
    end
  end
  
  def synchronize(&block)
    if @mutex.try_lock
      begin
        block.call
      ensure
        @mutex.unlock
      end
    else
      raise IllegalStateError.new('Mutex already locked')
    end
  end
  
  def unlock 
    return @mutex.unlock
  end
  
end


class TestConcurrency < Test::Unit::TestCase

  include TestBucketBase

  def test_concurrent_transactions_not_possible
    with_new_empty_db(NonBlockingMutex.new) do |db|
    
      # Create a fiber that starts a transaction and then halts, 
      # and run it until the halting point
      fiber1 = Fiber.new do
        db.transaction { Fiber.yield }
      end
      fiber1.resume

      # Create a thread that tries to start a transaction
      fiber2 = Fiber.new do
        db.transaction { :just_something }
      end

      # Since fiber1 is halted with the mutex locked running fiber2 should
      # raise an exception since we are using the non blocking mutex.
      assert_raise(IllegalStateError) { fiber2.resume }
      
      # Resume fiber1 to unlock the mutex, so that it is possible
      # to close the database.
      assert_nothing_raised { fiber1.resume }
    end
  end
  
end

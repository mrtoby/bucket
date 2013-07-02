#!/usr/bin/env ruby

require 'sourcify'
require './clock'
require './errors'
require './storage'

class Bucket

  attr_reader :name, :at_version_id, :clock

  def initialize(name, mutex = nil)
    @name = name
    @at_version_id = nil
    @storage_class = MemoryStorage
    @storage = nil
    @data_object_class = Class.new
    @data_object = nil
    @data_object_binding = nil
    @clock = nil
    if mutex.nil?
      @mutex = Mutex.new
    else
      @mutex = mutex
    end
  end

  def data_object_class=(data_object_class)
    @mutex.synchronize do
      must_be_closed
      @data_object_class = data_object_class
    end
  end
  
  def storage_class=(storage_class)
    @mutex.synchronize do
      must_be_closed
      @storage_class = storage_class
    end
  end
  
  def open
    @mutex.synchronize do
      must_be_closed
      @storage = @storage_class.new(@name)
      @storage.open
      restore_from_storage
    end
  end

  def open?
    @mutex.synchronize do
      unsynchronized_open?
    end
  end

  def just_created?
    @mutex.synchronize do
      @at_version_id == 0
    end
  end

  def transaction(*params, &block)
    if not block_given?
      return nil
    end
    proc_str = proc_as_string(block)
    @mutex.synchronize do
      must_be_open
      begin
        @clock.with_fixed_time do
          result = eval_transaction(proc_str, params, &block)
          @storage.log_transaction(@clock.now, 
                                   @at_version_id + 1, 
                                   proc_str, 
                                   params)
          @at_version_id += 1
          return result
        end
      rescue => e
        restore_from_storage
        raise TransactionFailedError.new(@at_version_id, e)
      end
    end
  end

  def take_snapshot
    @mutex.synchronize do
      must_be_open
      @storage.take_snapshot(@data_object, @at_version_id)
    end
  end

  def inspect
    "Database with name #{@name} currently at transaction #{@at_version_id}"
  end

  def close
    @mutex.synchronize do
      must_be_open
      @storage.close
      @storage = nil
      use_clock(nil)
      @data_object = nil
      @data_object_binding = nil
      @at_version_id = -1
    end
  end

  private

  def use_clock(clock)
    @clock = clock
    if not(@data_object.nil?)
      @data_object.instance_variable_set(:@clock, clock);
    end
  end
 
  def eval_transaction(proc_str, params, &block)
#    if fast_mode? and block_given?
#      @data_object.instance_exec(*params, &block)	
#    else
      proc = eval(proc_str, @data_object_binding)
      proc.call(*params)
#     end
  end

  def restore_from_storage
    if @storage.has_snapshot?
      restore_latest_snapshot
    else
      create_data_object
    end
    apply_logged_transactions
    use_clock(Clock.new)
  end

  def restore_latest_snapshot
    @at_version_id = @storage.latest_snapshot_version
    @data_object = @storage.restore_latest_snapshot
    @data_object_binding = @data_object.instance_eval { binding }
    add_clock_method(@data_object)
  end

  def add_clock_method(obj)
    obj.instance_eval { def clock; @clock; end }
  end

  def create_data_object
    @at_version_id = 0
    @data_object = @data_object_class.new
    @data_object_binding = @data_object.instance_eval { binding }
    add_clock_method(@data_object)
  end

  def apply_logged_transactions
    use_clock(Clock.new)
    @clock.pause
    @storage.each_transaction(@at_version_id + 1) do |t, v, proc_str, params|
      @clock.travel_to(t)
      eval_transaction(proc_str, params)
      @at_version_id = v
    end
  end

  def proc_as_string(proc)
    return proc.to_source
  end
  
  def must_be_open
    if not(unsynchronized_open?)
      raise IllegalStateError.new("Not open")
    end
  end

  def must_be_closed
    if unsynchronized_open?
      raise IllegalStateError.new("Not closed")
    end
  end

  def unsynchronized_open?  
    return not(@storage.nil?)
  end
end

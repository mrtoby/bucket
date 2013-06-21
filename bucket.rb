#!/usr/bin/env ruby

require 'sourcify'
require './storage'
require './clock'
require './errors'

class Bucket

  attr_reader :name, :at_version_id, :clock

  def self.destroy(db_name)
    MemoryStorage.destroy(db_name)
  end

  def initialize(name, data_object_class = nil)
    @name = name
    @at_version_id = nil
    @storage = nil
    if data_object_class.nil?
      @data_object_class = Class.new
    else
      @data_object_class = data_object_class
    end
    @data_object = nil
    @data_object_binding = nil
    @clock = nil
    fast_mode
    @mutex = Mutex.new
  end

  def fast_mode
    @mode = :fast
  end

  def safe_mode
    @mode = :safe
  end

  def fast_mode?
    @mode == :fast
  end

  def safe_mode?
    @mode == :safe
  end

  def open
    @mutex.synchronize do
      if is_open?
        raise IllegalStateError.new("Already open")
      end
      @storage = MemoryStorage.new(@name)
      @storage.open
      restore_from_storage
    end
  end

  def open?
    not(@storage.nil?)
  end
  
  def new?
    @at_version_id == 0
  end

  def transaction(*params, &block)
    if not block_given?
      return nil
    end
    proc_str = proc_as_string(block)
    @mutex.synchronize do
      begin
        @clock.with_fixed_time do
          result = eval_transaction(block, proc_str, params)
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
      @storage.take_snapshot(@data_object, @at_version_id)
    end
  end

  def inspect
    "Database with name #{@name} currently at transaction #{@at_version_id}"
  end

  def close
    @mutex.synchronize do
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
 
  def eval_transaction(proc, proc_str, params)
    if fast_mode? and not(proc.nil?)
      @data_object_binding.instance_exec(*params) &proc
    else
      proc = eval(proc_str, @data_object_binding)
      proc.call(*params)
    end
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
      eval_transaction(nil, proc_str, params)
      @at_version_id = v
    end
  end

  def proc_as_string(proc)
    proc.to_source
  end

end

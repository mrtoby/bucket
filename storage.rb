#!/usr/bin/env ruby

require './errors'

# Class that support the bucket database with persistence, multiple
# different implementations of the storage is possible.
class Storage

  Transaction = Struct.new(:transaction_time,
                           :version_id_after_transaction,
                           :proc_str,
                           :params)
  
  @@log_registry = Hash.new

  # Class method used to destroy an existing database. 
  def self.destroy(db_name)
    @@log_registry.delete(db_name)
  end

  def initialize(name)
    @name = name
    @transaction_log = nil
  end

  # To be able to use the storage, it should first be opened
  def open
    if is_open?
      raise IllegalStateError.new("Already open")
    end
    @transaction_log = Storage.fetch_log(@name)
  end

  def is_open?
    not(@transaction_log.nil?)
  end

  def has_snapshot?
    must_be_open
    false
  end

  def latest_snapshot_version
    must_be_open
    raise "Not implemented"
  end
 
  def restore_latest_snapshot
    must_be_open
    raise "Not implemented"
  end

  def log_transaction(transaction_time,
                      version_id_after_transaction, 
                      proc_str, 
                      params)
    must_be_open
    trans = Transaction.new(transaction_time, version_id_after_transaction, proc_str, params)
    @transaction_log << trans
  end

  def take_snapshot(data_object, at_version_id)
    must_be_open
    raise "Not implemented"
  end

  def each_transaction(from_version_id, &block)
    must_be_open
    @transaction_log.each do |trans|
      if trans.version_id_after_transaction >= from_version_id
        yield(trans.transaction_time, 
              trans.version_id_after_transaction, 
              trans.proc_str, 
              trans.params)
      end
    end
  end

  def close
    must_be_open
    @transaction_log = nil
  end

  private

  def self.fetch_log(db_name)
    log = @@log_registry[db_name]
    if log.nil?
      log = Array.new
      @@log_registry[db_name] = log
    end
    log
  end

  def must_be_open
    if not(is_open?)
      raise IllegalStateError.new("Not open")
    end
  end

end

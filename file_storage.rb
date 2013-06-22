#!/usr/bin/env ruby

require './errors'

# Class that support the bucket database with persistence, multiple
# different implementations of the storage is possible.
class MemoryStorage

  Transaction = Struct.new(:transaction_time,
                           :version_id_after_transaction,
                           :proc_str,
                           :params)
  

  # Class method used to destroy an existing database. 
  def self.destroy(db_name)
    # TODO
  end

  def initialize(name)
    # TODO
  end

  # To be able to use the storage, it should first be opened
  def open
    if open?
      raise IllegalStateError.new("Already open")
    end
    # TODO
  end

  def open?
    # TODO
  end

  def has_snapshot?
    must_be_open
    # TODO
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
    # TODO
  end

  def take_snapshot(data_object, at_version_id)
    must_be_open
    # TODO
  end

  def each_transaction(from_version_id, &block)
    must_be_open
    # TODO
  end

  def close
    must_be_open
    # TODO
  end

  Privat

  

  def must_be_open
    if not(open?)
      raise IllegalStateError.new("Not open")
    end
  end

end

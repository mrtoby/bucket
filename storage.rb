#!/usr/bin/env ruby

require './errors'

# Class that support the bucket database with persistence, multiple
# different implementations of the storage is possible.
class FileStorage

  Transaction = Struct.new(:transaction_time,
                           :version_id_after_transaction,
                           :proc_str,
                           :params)
  
  Snapshot = Struct.new(:snapshot_time,
                        :latest_version_id_in_snapshot,
                        :data_object)
                        
  # Class method used to destroy an existing database. 
  def self.destroy(db_name)
    if try_lock_folder(db_name)
      File.delete(db_name)
    else
      raise IllegalStateError("Could not lock folder")
    end
  end

  def initialize(name)
    @folder = name
  end

  # To be able to use the storage, it should first be opened
  def open
    if open?
      raise IllegalStateError.new("Already open")
    end
    if try_lock_folder(@folder)
      # TODO: Figure out what the last transaction id is
    else
      raise IllegalStateError.new("Could not lock folder")
    end
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
    unlock_folder(@folder)
    # TODO
  end

  private

  def must_be_open
    if not(open?)
      raise IllegalStateError.new("Not open")
    end
  end

  def try_lock_folder
  end
  
  def unlock_folder
  end
  
end


# Class that support the bucket database with persistence, multiple
# different implementations of the storage is possible.
class MemoryStorage

  Transaction = Struct.new(:transaction_time,
                           :version_id_after_transaction,
                           :proc_str,
                           :params)
	
  @@log_registry = Hash.new
  @@log_lock = Hash.new
  @@mutex = Mutex.new

  # Class method used to destroy an existing database. 
  def self.destroy(db_name)
    @@mutex.synchronize do
      @@log_registry.delete(db_name)
      @@log_registry.delete(db_name)
    end
  end

  def initialize(name)
    @name = name
    @transaction_log = nil
  end

  # To be able to use the storage, it should first be opened
  def open
    if open?
      raise IllegalStateError.new("Already open")
    end
    @transaction_log = self.class.fetch_log(@name)
  end

  def open?
    return not(@transaction_log.nil?)
  end

  def has_snapshot?
    must_be_open
    return false
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
    self.class.release_log(@name)
    @transaction_log = nil
  end

  private

  def self.fetch_log(db_name)
    @@mutex.synchronize do
      if @@log_lock[db_name] == 1
        raise IllegalStateError.new("Storage already in use")
      end
      log = @@log_registry[db_name]
      if log.nil?
        log = Array.new
        @@log_registry[db_name] = log
      end
      @@log_lock[db_name] = 1
      return log
    end
  end

  def self.release_log(db_name)
    @@mutex.synchronize do
      if @@log_lock[db_name] != 1
        raise IllegalStateError.new("Storage not in use")
      end
      @@log_lock.delete(db_name)
    end    
  end

  def must_be_open
    if not(open?)
      raise IllegalStateError.new("Not open")
    end
  end

end

#!/usr/bin/env ruby

require './bucket'
require './storage'

module TestBucketBase

  @@db_name = 'test_db'
  
  def with_new_empty_db(mutex = nil, &block)   
    db = create_mem_db(mutex)
    db.open
    begin
      block.call(db)
    ensure
      db.close
    end
  end
  
  def with_new_db(klass, mutex = nil, &block)
    db = create_mem_db(mutex)
    db.data_object_class = klass
    db.open
    begin
      block.call(db)
    ensure
      db.close
    end
  end
  
  private
  
  def create_mem_db(mutex)
    begin
      MemoryStorage.destroy(@@db_name)
    rescue
      # Don't care
    end
    db = Bucket.new(@@db_name, mutex)
    db.storage_class = MemoryStorage
    return db
  end
  
end

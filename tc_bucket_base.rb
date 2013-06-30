#!/usr/bin/env ruby

require './bucket'
require './memory_storage'

module TestBucketBase

  @@db_name = 'test_db'

  def with_new_empty_db(&block)   
    begin
      MemoryStorage.destroy(@@db_name)
    rescue
      # Don't care
    end
    db = Bucket.new(@@db_name, Class.new, MemoryStorage)
    db.open
    begin
      block.call(db)
    ensure
      db.close
    end
  end
  
  def with_new_db(klass, &block)
    begin
      MemoryStorage.destroy(@@db_name)
    rescue
      # Don't care
    end
    db = Bucket.new(@@db_name, klass, MemoryStorage)
    db.open
    begin
      block.call(db)
    ensure
      db.close
    end
  end
  
end

#!/usr/bin/env ruby

require './bucket'

module TestBucketBase

  @@db_name = 'test_db'

  def open_new_empty_db
    begin
      Bucket.destroy(@@db_name)
    rescue
      # Don't care
    end
    db = Bucket.new(@@db_name)
    db.open
    db
  end

  def open_new_db(klass)
    begin
      Bucket.destroy(@@db_name)
    rescue
      # Don't care
    end
    db = Bucket.new(@@db_name, klass)
    db.open
    db
  end

end


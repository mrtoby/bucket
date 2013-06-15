#!/usr/bin/env ruby

require './bucket'

db = Bucket.new("my-first-db")
db.open
db.transaction(4710) { |n| @favorite_parfume = n }
n = db.transaction { @favorite_parfume += 1 }
puts "My favorite parfume is #{n}"
db.close

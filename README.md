Bucket
======

Bucket is a simple persistence system for ruby, strongly inspired by prevayler. I found two other
similar projects but I wanted something really simple to use and also add a little bit more ruby
style to it.

The other projects use command objects that encapsulate the command arguments and the actual
command that is beeing performed on the data object. A strong concept in ruby is the use of blocks
to encapsulate code, and when using bucket you simply use blocks:

```ruby
db = Bucket.new("my-first-db")
db.open
db.transaction(4710) { |n| @favorite_parfume = n }
n = db.transaction { @favorite_parfume += 1 }
puts "My favorite parfume is #{n}"
db.close
```

At row 1 a new database is created using an "empty" object as data container, you can also pass 
a class as the second object and when needed an instance will be created and used as the initial
object for the database. The second row will simply open the database.

The third row performs a transaction that changes the object by adding and assigning av value to 
a field. Any value that is needed in the transaction must be passed as an argument to the block.
This makes it possible to store these parameters and makes it possible to evaluate the exactly
same transaction once more. By using some ruby-woodo the transaction block will not be able to
access variables from the scope outside the transaction in any other way but using this mechanism.

Row 4 shows transaction that don't use any external data, but still modifies the database. When you 
don't need a parameter, you simply avoid it. The last expression in the transaction is returned 
to the caller, just like any other block. It is perfectly normal to have transactions that only
read data from the database.

The last row just closes the database.

One semantic difference between a transaction block and a normal ruby block is that only variables declared as block parameters will be accessible. And the block is evaluated inside the data object, so self will be set to that object. In the example above, when no data object is specified, an "empty" object will be used as data object. For example: the variable db is not accessible in the transaction.

The intention of "bucket" is to make it easy to implement persistence. High performance is not the goal.

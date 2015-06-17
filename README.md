**fire-model**

Setup Firebase
```ruby
Fire.setup(firebase_path: 'https://some-test-777.firebaseio.com')
```

Declare your Model
```ruby
class LibraryBook < Fire::Model
  has_path_keys(:library, :floor, :row_number, :shelf)
end
```

Use query syntax
```ruby
LibraryBook.create(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 10, name: 'Kobzar', author: 'T.G. Shevchenko')
LibraryBook.create(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 15, name: 'Eneida', author: 'I. Kotlyrevskiy')
LibraryBook.create(library: 'Shevchenko', floor: 2, row_number: 15, shelf: 115, name: 'Lord Of The Rings', author: ' J.R.R. Tolkien')
LibraryBook.create(library: 'Skovoroda', floor: 1, row_number: 25, shelf: 34, name: 'Harry Potter', author: 'J.K. Rowling')
LibraryBook.create(library: 'Skovoroda', floor: 2, row_number: 12, shelf: 15, name: 'Hobbit', author: ' J.R.R. Tolkien')

expect(LibraryBook.all.map(&:name)).to eq([ 'Kobzar', 'Eneida', 'Lord Of The Rings', 'Harry Potter', 'Hobbit' ])

# Query by library
LibraryBook.query(library: 'Shevchenko').map(&:name)
=> [ 'Kobzar', 'Eneida', 'Lord Of The Rings' ]
LibraryBook.query(library: 'Skovoroda').map(&:name)
=> [ 'Harry Potter', 'Hobbit' ]

# Query by library, floor
LibraryBook.query(library: 'Shevchenko', floor: 1).map(&:name)
=> [ 'Kobzar', 'Eneida' ]

# Query by library, floor, row
LibraryBook.query(library: 'Shevchenko', floor: 1, row_number: 1).map(&:name)
=> [ 'Kobzar', 'Eneida' ]

# Query by shelf
LibraryBook.query(shelf: 15).map(&:name)
=> [ 'Eneida', 'Hobbit' ]

# Query by author
LibraryBook.query(author: ' J.R.R. Tolkien').map(&:name) 
=> [ 'Lord Of The Rings', 'Hobbit' ]

# Query by math condition
LibraryBook.query{|m| m.row_number % 5 == 0  }.map(&:name)
=> [ 'Lord Of The Rings', 'Harry Potter' ]
```
Play with CRUD
```ruby
class Point < Fire::Model
  has_path_keys(:x, :y)
end

p1 = Point.create(x: 1, y: 1, value: 1)
p2 = Point.create(x: 1, y: 2, value: 2)
p3 = Point.create(x: 2, y: 1, value: 3)
p4 = Point.create(x: 1, y: 1, value: 4)

Point.all.map(&:value)
=> [ 1, 2, 3, 4 ]

p1.value = 5
p1.path_changed?
=> false

p1.save

reloaded_point = Point.take(x: p2.x, y: p2.y, id: p2.id)
reloaded_point.value = 6

reloaded_point.path_changed?
=> false

reloaded_point.save

p1.delete

Point.all.map(&:value)
=> [ 6, 3, 4]

p3.x = 4
p3.path_changed?
=> true

p3.save

Point.all.map(&:value)
=> [ 6, 3, 4]
```


**Contributing to fire-model**
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

== Copyright

Copyright (c) 2015 Vitaly Tarasenko. See LICENSE.txt for
further details.


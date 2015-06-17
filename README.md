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
expect(LibraryBook.query(library: 'Shevchenko').map(&:name)).to eq([ 'Kobzar', 'Eneida', 'Lord Of The Rings' ])
expect(LibraryBook.query(library: 'Skovoroda').map(&:name)).to eq([ 'Harry Potter', 'Hobbit' ])

# Query by library, floor
expect(LibraryBook.query(library: 'Shevchenko', floor: 1).map(&:name)).to eq([ 'Kobzar', 'Eneida' ])

# Query by library, floor, row
expect(LibraryBook.query(library: 'Shevchenko', floor: 1, row_number: 1).map(&:name)).to eq([ 'Kobzar', 'Eneida' ])

# Query by shelf
expect(LibraryBook.query(shelf: 15).map(&:name)).to eq([ 'Eneida', 'Hobbit' ])

# Query by author
expect(LibraryBook.query(author: ' J.R.R. Tolkien').map(&:name)).to eq([ 'Lord Of The Rings', 'Hobbit' ])

# Query by math condition
expect(LibraryBook.query{|m| m.row_number % 5 == 0  }.map(&:name)).to eq([ 'Lord Of The Rings', 'Harry Potter' ])
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


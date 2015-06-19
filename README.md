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
Play with CRUD
```ruby
class Point < Fire::Model
  has_path_keys(:x, :y)
end

p1 = Point.create(x: 1, y: 1, value: 1)
p2 = Point.create(x: 1, y: 2, value: 2)
p3 = Point.create(x: 2, y: 1, value: 3)
p4 = Point.create(x: 1, y: 1, value: 4)

expect(Point.all.map(&:value).sort).to eq([ 1, 2, 3, 4 ].sort)

p1.value = 5
expect(p1.path_changed?).to be_falsey
p1.save

expect(Point.all.map(&:value).sort).to eq([ 5, 2, 3, 4 ].sort)

reloaded_point = Point.take(x: p2.x, y: p2.y, id: p2.id)
reloaded_point.value = 6

expect(reloaded_point.path_changed?).to be_falsey

reloaded_point.save

expect(Point.all.map(&:value).sort).to eq([ 5, 6, 3, 4 ].sort)

p1.delete

expect(Point.all.map(&:value).sort).to eq([ 6, 3, 4].sort)

p3.x = 4
expect(p3.path_changed?).to be_truthy
p3.save

expect(Point.all.map(&:value).sort).to eq([ 6, 3, 4].sort)
```

Create Nested Models
```ruby
class Organization < Fire::Model
  has_path_keys :country, :state
  set_id_key(:name)
end

class Employee < Fire::NestedModel
  nested_in Organization, folder: 'employees'
  has_path_keys :department
end

google = Organization.create(name: 'Google', country: 'USA', state: 'CA')
apple = Organization.create(name: 'Apple', country: 'USA', state: 'CA')

larry = Employee.create(name: 'Google', country: 'USA', state: 'CA',
  department: 'HQ', full_name: 'Larry Page', position: 'CEO')
  
employee = Organization.query(name: 'Google').first.nested_employees.first
larry == employee
=> true
  
tim = apple.add_to_employees(
  full_name: 'Tim Cook',
  position: 'CEO',
  department: 'HQ'
)

Fire.connection.get(?/).body
=> {'Organization'=>
             {'usa'=>
                  {'ca'=>
                       {'apple'=>
                            {'country'=>'USA',
                             'employees'=>
                                 {'hq'=>
                                      {'h543ka'=>
                                           {'department'=>'HQ',
                                            'full_name'=>'Tim Cook',
                                            'id'=>'h543ka',
                                            'position'=>'CEO'}}},
                             'name'=>'Apple',
                             'state'=>'CA'},
                        'google'=>
                            {'country'=>'USA',
                             'employees'=>
                                 {'research'=>
                                      {'d23h1a'=>
                                           {'department'=>'Research',
                                            'full_name'=>'Larry Page',
                                            'id'=>'d23h1a',
                                            'position'=>'CEO'}}},
                             'name'=>'Google',
                             'state'=>'CA'}}}}}


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


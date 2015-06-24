# fire-model - REST wrapper for Firebase.

Install gem
```
gem install fire-model
```

Setup Firebase. (If you are using Rails create a file `Rails.root/config/initializers/fire_model.rb` and put next line there)
```ruby
require 'fire-model'
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
LibraryBook.create(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 10, 
  name: 'Kobzar', author: 'T.G. Shevchenko')
LibraryBook.create(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 15, 
  name: 'Eneida', author: 'I. Kotlyrevskiy')
LibraryBook.create(library: 'Shevchenko', floor: 2, row_number: 15, shelf: 115, 
  name: 'Lord Of The Rings', author: ' J.R.R. Tolkien')
LibraryBook.create(library: 'Skovoroda', floor: 1, row_number: 25, shelf: 34, 
  name: 'Harry Potter', author: 'J.K. Rowling')
LibraryBook.create(library: 'Skovoroda', floor: 2, row_number: 12, shelf: 15, 
  name: 'Hobbit', author: ' J.R.R. Tolkien')

LibraryBook.all.map(&:name)
=> [ 'Kobzar', 'Eneida', 'Lord Of The Rings', 'Harry Potter', 'Hobbit' ]

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

employee.department = 'Research'
employee.save
=> true

google.reload
  
tim = apple.add_to_employees(
  full_name: 'Tim Cook',
  position: 'CEO',
  department: 'HQ'
)

Fire.tree
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
Single Nested Models
```ruby
class Car < Fire::Model
  has_path_keys :manufacturer, :model, :car_class
end

class Engine < Fire::SingleNestedModel
  nested_in Car
end

scirocco = Car.create(manufacturer: 'Volkswagen', model: 'Scirocco', car_class: 'Sport compact')
scirocco.add_to_engine(code: 'I4 turbo', power: '122 PS')

car = Car.create(manufacturer: 'Zaporozhets', model: 'ZAZ-965', car_class: 'Mini', 
  engine: { code: 'MeMZ-966' })

zaporozhets = Car.take(manufacturer: 'Zaporozhets', model: 'ZAZ-965', car_class: 'Mini', id: car.id)
zaporozhets.nested_engine.code
=> 'MeMZ-966'

Fire.tree
=> {
  'Car'=>
    {'volkswagen'=>
         {'scirocco'=>
              {'sport-compact'=>
                   {'adqa21'=>
                        {'car_class'=>'Sport compact',
                         'engine'=>{'code'=>'I4 turbo', 'power'=>'122 PS'},
                         'id'=>'adqa21',
                         'manufacturer'=>'Volkswagen',
                         'model'=>'Scirocco'}}}},
     'zaporozhets'=>
         {'zaz-965'=>
              {'mini'=>
                   {'23rtfw'=>
                        {'car_class'=>'Mini',
                         'engine'=>{'code'=>'MeMZ-966'},
                         'id'=>'23rtfw',
                         'manufacturer'=>'Zaporozhets',
                         'model'=>'ZAZ-965'}}}}}})

zap2 = Car.take(manufacturer: 'Zaporozhets', model: 'ZAZ-965', car_class: 'Mini', id: car.id)
zap2.nested_engine.update(code: 'MeMZ-555')
zaporozhets.nested_engine.reload.code
=> 'MeMZ-555'
```

Nested Models with Parent`s values
```ruby
class House < Fire::Model
  has_path_keys :country, :city, :street
  set_id_key(:house_number)
end

class Room < Fire::NestedModel
  nested_in House, parent_values: true
  set_id_key(:number)
  has_path_keys :floor
end

house = House.create(country: 'Ukraine', city: 'Kyiv', 
  street: 'Shevchenko Ave.', house_number: '53101')
  
house.add_to_rooms(floor: 200, number: '1A')
house.add_to_rooms(floor: 150, number: '2A')


rooms = house.reload.nested_rooms
rooms.map(&:number)
=> [ '1A', '2A' ]

Fire.tree
=>  {'House'=>
      {'ukraine'=>
           {'kyiv'=>
                {'shevchenko-ave'=>
                     {'53101'=>
                          {'city'=>'Kyiv',
                           'country'=>'Ukraine',
                           'house_number'=>'53101',
                           'rooms'=>
                               {'150_'=>
                                    {'2a'=>
                                         {'city'=>'Kyiv',
                                          'country'=>'Ukraine',
                                          'floor'=>150,
                                          'number'=>'2A',
                                          'house_number'=>'53101',
                                          'street'=>'Shevchenko Ave.'}},
                                '200_'=>
                                    {'1a'=>
                                         {'city'=>'Kyiv',
                                          'country'=>'Ukraine',
                                          'floor'=>200,
                                          'number'=>'1A',
                                          'house_number'=>'53101',
                                          'street'=>'Shevchenko Ave.'}}},
                           'street'=>'Shevchenko Ave.'}}}}}})
```


**Contributing to fire-model**
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

**Copyright**

Copyright (c) 2015 Vitaly Tarasenko. See LICENSE.txt for
further details.


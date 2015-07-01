require 'spec_helper'

describe 'Fire Models' do

  before :each do
    Fire.drop!
  end

  after :each do
    Fire.drop!
  end

  it 'should have a collection & connection' do
    fm = Fire::Model.new
    expect(fm.collection_name).to eq('Model')
    expect(Fire::Model.connection).to be_a(Fire::Connection::Request)
  end

  it 'should have subclasses with own collection names' do
    class SampleModel < Fire::Model
    end

    class SecondModel < Fire::Model
      in_collection 'PerfectModel'
    end

    class ThirdModel < Fire::Model
      in_collection 'BestModel'
    end

    sm1 = SampleModel.new
    expect(sm1.collection_name).to eq('SampleModel')

    sm2 = SecondModel.new
    expect(sm2.collection_name).to eq('PerfectModel')

    sm3 = ThirdModel.new
    expect(sm3.collection_name).to eq('BestModel')
  end

  it 'should build paths for simple subclasses' do

    class TestModel < Fire::Model
      in_collection 'ExampleModel'
    end

    tm = TestModel.new
    expect(tm.id).to be
    expect(tm.path_values.count).to eq(1)

    tm.id = 'id_first'
    expect(tm.to_h).to eq({ id: 'id_first' })
    expect(tm.path_values).to eq([ 'id_first' ])
    expect(tm.path).to eq('ExampleModel/id_first')

    tm = TestModel.new(id: 'id_second')
    expect(tm.id).to be
    expect(tm.path_values).to eq([ 'id_second' ])
    expect(tm.path).to eq('ExampleModel/id_second')
  end

  it 'should compare attributes' do

    class SomeModel < Fire::Model
    end

    tm = SomeModel.new(value: 1, name: 'a')

    expect(tm.has_data?(value: 1)).to be_truthy
    expect(tm.has_data?(value: 1, name: 'a')).to be_truthy
    expect(tm.has_data?('name' => 'a')).to be_truthy
    expect(tm.has_data?(value: 2)).to be_falsey

    expect(tm == SomeModel.new(tm.to_h)).to be_truthy
  end


  it 'should build paths for subclasses with custom path keys' do

    class Address < Fire::Model
      has_path_keys(:country, :region, :city, :street, :number)
    end

    ad = Address.new(country: 'Ukraine', region: 'Cherkasy', city: 'Cherkasy')
    expect(ad.id).to be
    expect(->{
      ad.path
    }).to raise_error(Fire::Model::PathValueMissingError)

    ad.id = 'my_id'
    ad.street = 'Some Street'
    ad.number = 101
    expect(ad.path).to eq('Address/ukraine/cherkasy/cherkasy/some-street/101_/my_id')
  end

  context 'Persistence' do

    class Animal < Fire::Model
      has_path_keys(:kingdom, :phylum, :subphylum, :class, :order, :family)
    end

    let(:rabbit_path_data) do
      {
          kingdom: 'Animalia',
          phylum: 'Chordata',
          subphylum: 'Vertebrata',
          class: 'Mammalia',
          order: 'Lagomorpha',
          family: 'Leporidae',
      }
    end

    it 'should query save/delete object with path keys' do
      expect(Animal.all).to eq([])
      expect(Animal.take(rabbit_path_data)).to be_nil

      rabbit = Animal.new(rabbit_path_data.merge(name: 'Bunny', age: 2))
      expect(rabbit.persisted?).to be_falsey

      rabbit.save
      expect(rabbit.persisted?).to be_truthy

      loaded_rabbit = Animal.take(rabbit_path_data.merge(id: rabbit.id))
      expect(loaded_rabbit.persisted?).to be_truthy

      expect(loaded_rabbit).to eq(rabbit)

      expect(loaded_rabbit).to be_a(Animal)
      expect(loaded_rabbit.age).to eq(2)
      expect(loaded_rabbit.name).to eq('Bunny')
      expect(loaded_rabbit.kingdom).to eq('Animalia')

      expect(Animal.all).to eq([ loaded_rabbit ])

      loaded_rabbit.delete

      expect(Animal.all).to eq([ ])
    end


    context 'Querying & Filtering' do

      it 'should perform complex queries & filters' do

        class LibraryBook < Fire::Model
          has_path_keys(:library, :floor, :row_number, :shelf)
        end

        book = LibraryBook.create(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 10, name: 'Kobzar', author: 'T.G. Shevchenko')
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

        # Query by full path
        expect(LibraryBook.query(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 10).map(&:name)).to eq([ 'Kobzar' ])

        # Take by full path + ID
        expect(LibraryBook.take(library: 'Shevchenko', floor: 1, row_number: 1, shelf: 10, id: book.id).name).to eq('Kobzar')
      end

    end

    context 'Updating' do

      it 'should update data (default ID key)' do

        class Point < Fire::Model
          has_path_keys(:x, :y)
        end

        # Creating
        p1 = Point.create(x: 1, y: 1, value: 1)
        p2 = Point.create(x: 1, y: 2, value: 2)
        p3 = Point.create(x: 2, y: 1, value: 3)
        p4 = Point.create(x: 1, y: 1, value: 4)

        expect(Point.all.map(&:value).sort).to eq([ 1, 2, 3, 4 ].sort)

        # ID generation
        expect(p1.id).to be

        # Updating
        p1.value = 5
        expect(p1.path_changed?).to be_falsey
        p1.save


        expect(Point.all.map(&:value).sort).to eq([ 5, 2, 3, 4 ].sort)

        reloaded_point = Point.take(x: p2.x, y: p2.y, id: p2.id)
        reloaded_point.update(value: 6)

        expect(reloaded_point.path_changed?).to be_falsey

        reloaded_point.save
        expect(Point.all.map(&:value).sort).to eq([ 5, 6, 3, 4 ].sort)

        # Reloading
        expect(p2.value).to eq(2)
        p2.reload
        expect(p2.value).to eq(6)

        # Deletion
        p1.delete

        expect(Point.all.map(&:value).sort).to eq([ 6, 3, 4].sort)

        p3.x = 4
        expect(p3.path_changed?).to be_truthy
        p3.save

        expect(Point.all.map(&:value).sort).to eq([ 6, 3, 4].sort)
      end

      it 'should update data (custom ID key)' do
        class Point < Fire::Model
          has_path_keys(:x, :y)
          set_id_key(:z)
        end

        p1 = Point.create(x: 1, y: 1, value: 1)
        expect(p1.z).to be
        expect(p1.id).to be_nil

        p1.z = 10
        p1.save

        reloaded_point = Point.take(x: 1, y: 1, z: 10)

        expect(reloaded_point).to eq(p1)
      end

      it 'should update/delete a field' do
        class Box < Fire::Model
          has_path_keys :a, :b
        end

        box = Box.create(id: 'box', a: 'a', b: 'b', slot1: 1, slot2: 2)

        expect(Fire.tree).to eq({'Box'=>{'a'=>{'b'=>
          {
              'box'=>{'a'=>'a', 'b'=>'b', 'id'=>'box', 'slot1'=>1, 'slot2'=>2}
          }
        }}})

        box.update_field(:slot1, 3)

        expect(Fire.tree).to eq({'Box'=>{'a'=>{'b'=>
          {
             'box'=>{'a'=>'a', 'b'=>'b', 'id'=>'box', 'slot1'=>3, 'slot2'=>2}
          }
        }}})

        box.update_field(:slot3, 4)

        expect(Fire.tree).to eq({'Box'=>{'a'=>{'b'=>
          {
             'box'=>{'a'=>'a', 'b'=>'b', 'id'=>'box', 'slot1'=>3, 'slot2'=>2, 'slot3'=> 4}
          }
        }}})

        box.delete_field(:slot3)

        expect(Fire.tree).to eq({'Box'=>{'a'=>{'b'=>
          {
             'box'=>{'a'=>'a', 'b'=>'b', 'id'=>'box', 'slot1'=>3, 'slot2'=>2}
          }
        }}})
      end

    end

  end

end

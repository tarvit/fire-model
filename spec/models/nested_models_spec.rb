require 'spec_helper'

describe 'Nested Models' do

  before :each do
    Fire.drop!
  end

  after :each do
    Fire.drop!
  end

  it 'should declare nested models' do

    class Organization < Fire::Model
      has_path_keys :country, :state
      set_id_key(:name)
    end

    expect(Organization.nested_models).to be_empty

    class Employee < Fire::NestedModel
      nested_in Organization
      has_path_keys :department
    end

    expect(Organization.nested_models).to eq([ Employee ])

    google = Organization.create(name: 'Google', country: 'USA', state: 'CA')
    apple = Organization.create(name: 'Apple', country: 'USA', state: 'CA')

    expect(current_data).to eq(
        {'Organization'=>
                {'usa'=>
                     {'ca'=>
                          {'apple'=>{'country'=>'USA', 'name'=>'Apple', 'state'=>'CA'},
                           'google'=>{'country'=>'USA', 'name'=>'Google', 'state'=>'CA'}}}}})

    larry = Employee.create(name: 'Google', country: 'USA', state: 'CA',
                    department: 'HQ', full_name: 'Larry Page', position: 'CEO')

    expect(current_data).to eq(
        {'Organization'=>
             {'usa'=>
                  {'ca'=>
                       {'apple'=>{'country'=>'USA', 'name'=>'Apple', 'state'=>'CA'},
                        'google'=>{
                            'country'=>'USA', 'name'=>'Google', 'state'=>'CA', 'employees' => {
                                'hq' => {
                                    larry.id => {
                                        'id' => larry.id,
                                        'full_name' => 'Larry Page',
                                        'position' => 'CEO',
                                        'department' => 'HQ',
                                    }}}}}}}})

    google = Organization.query(name: 'Google').first
    google.nested_employees

    employee = google.nested_employees.first
    expect(larry).to eq(employee)

    employee.department = 'Research'
    employee.save

    expect(current_data).to eq(
        {'Organization'=>
             {'usa'=>
                  {'ca'=>
                       {'apple'=>{'country'=>'USA', 'name'=>'Apple', 'state'=>'CA'},
                        'google'=>{
                            'country'=>'USA', 'name'=>'Google', 'state'=>'CA', 'employees' => {
                                'research' => {
                                    larry.id => {
                                        'id' => larry.id,
                                        'full_name' => 'Larry Page',
                                        'position' => 'CEO',
                                        'department' => 'Research',
                                    }}}}}}}})

    apple = Organization.query(name: 'Apple').first
    tim = apple.add_to_employees(
      full_name: 'Tim Cook',
      position: 'CEO',
      department: 'HQ'
    )

    expect(current_data).to eq(
        {'Organization'=>
             {'usa'=>
                  {'ca'=>
                       {'apple'=>
                            {'country'=>'USA',
                             'employees'=>
                                 {'hq'=>
                                      {tim.id=>
                                           {'department'=>'HQ',
                                            'full_name'=>'Tim Cook',
                                            'id'=>tim.id,
                                            'position'=>'CEO'}}},
                             'name'=>'Apple',
                             'state'=>'CA'},
                        'google'=>
                            {'country'=>'USA',
                             'employees'=>
                                 {'research'=>
                                      {larry.id=>
                                           {'department'=>'Research',
                                            'full_name'=>'Larry Page',
                                            'id'=>larry.id,
                                            'position'=>'CEO'}}},
                             'name'=>'Google',
                             'state'=>'CA'}}}}}
    )
  end

  context 'Nested Models Types' do

    it 'should declare single nested models' do

      class Car < Fire::Model
        has_path_keys :manufacturer, :model, :car_class
      end

      class Engine < Fire::SingleNestedModel
        nested_in Car
      end

      scirocco = Car.create(manufacturer: 'Volkswagen', model: 'Scirocco', car_class: 'Sport compact')
      scirocco.add_to_engine(code: 'I4 turbo', power: '122 PS')

      car = Car.create(manufacturer: 'Zaporozhets', model: 'ZAZ-965', car_class: 'Mini', engine: { code: 'MeMZ-966' })

      zaporozhets = Car.take(manufacturer: 'Zaporozhets', model: 'ZAZ-965', car_class: 'Mini', id: car.id)
      expect(zaporozhets.nested_engine.code).to eq('MeMZ-966')

      expect(current_data).to eq({
        'Car'=>
          {'volkswagen'=>
               {'scirocco'=>
                    {'sport-compact'=>
                         {scirocco.id=>
                              {'''car_class'=>'Sport compact',
                               'engine'=>{'code'=>'I4 turbo', 'power'=>'122 PS'},
                               'id'=>scirocco.id,
                               'manufacturer'=>'Volkswagen',
                               'model'=>'Scirocco'}}}},
           'zaporozhets'=>
               {'zaz-965'=>
                    {'mini'=>
                         {zaporozhets.id=>
                              {'car_class'=>'Mini',
                               'engine'=>{'code'=>'MeMZ-966'},
                               'id'=>zaporozhets.id,
                               'manufacturer'=>'Zaporozhets',
                               'model'=>'ZAZ-965'}}}}}})
    end

  end

  context 'Restrictions' do
    before :each do

      class Hotel < Fire::Model
        has_path_keys :location, :class
        set_id_key(:name)
      end

    end

    it 'should not allow to set path keys if parent model is not set' do
      expect(->{
        class Room < Fire::NestedModel
          has_path_keys :number
          nested_in Hotel, folder: 'rooms'
        end
      }).to raise_error(Fire::NestedModel::ParentModelNotSetError)

      expect(->{
        class Room < Fire::NestedModel
          nested_in Hotel, folder: 'rooms'
          has_path_keys :number
        end
      }).to be
    end

    it 'should not allow to declare duplicated path keys in nested models' do
      expect(->{
        class Room < Fire::NestedModel
          nested_in Hotel, folder: 'rooms'
          has_path_keys :number, :class
        end
      }).to raise_error(Fire::NestedModel::DuplicatedParentPathKeyError)

      expect(->{
        class Room < Fire::NestedModel
          nested_in Hotel, folder: 'rooms'
          has_path_keys :number, :room_class
        end
      }).to be
    end

    it 'should not allow to declare own path keys in single nested models' do
      expect(->{
        class Earth < Fire::Model

        end

        class Moon < Fire::SingleNestedModel
          nested_in Earth
          has_path_keys :planet
        end
      }).to raise_error(Fire::SingleNestedModel::PathKeysNotSupported)
    end
  end

  def current_data
    Fire.connection.get(?/).body
  end

end

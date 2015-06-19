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
      nested_in Organization, folder: 'employees'
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

  def current_data
    Fire.connection.get(?/).body
  end

end

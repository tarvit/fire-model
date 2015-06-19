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
                                    }}}}}}}})
  end

  def current_data
    Fire.connection.get(?/).body
  end

end

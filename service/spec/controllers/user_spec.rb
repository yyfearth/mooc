require_relative '../spec_helper'

# TODO
describe 'UserController' do
  include SpecCommon

  it 'creats a user' do
    request_data = {
        email: 'test@test.com',
        password: '',
        title: 'Test Discussion',
    }

    post '/discussion', request_data.to_json
    last_response.status.should == 201

    @vars[:discussion] = response_data = JSON.parse last_response.body

    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  it 'gets a user' do
    get '/users'
    puts last_response.body
    last_response.should be_ok
  end

  it 'updates a user' do
    get '/users'
    puts last_response.body
    last_response.should be_ok
  end

  it 'deletes a user' do
    get '/users'
    puts last_response.body
    last_response.should be_ok
  end
end

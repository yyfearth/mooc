require_relative '../spec_helper'

describe 'User API' do

  before :all do
    @vars = {}
  end

  it 'creates a user' do
    request_data = {
        email: ((0..6).map { (65 + rand(26)).chr }.join) << '@test.com',
        password: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', # the SHA-1 hash of text 'test'
        first_name: 'James',
        last_name: 'Smith',
        address: {
            address: '760 United Nations Plaza',
            city: 'New York',
            state: 'NY',
            zip: '10017',
            country: 'USA',
        },
    }

    post '/user', request_data.to_json
    last_response.status.should == 201
    last_response.body.nil?.should be_false
    @vars[:user] = JSON.parse(last_response.body)
  end

  it 'gets a user' do
    get '/user/' << @vars[:user]['email']
    last_response.status.should == 200
  end

  it 'updates a user' do
    request_data = {
        #email: ((0..6).map { (65 + rand(26)).chr }.join) << '@test.com',
        password: '0000000000000000000000000000000000000000',
        first_name: '~James',
        last_name: '~Smith',
        address: {
            address: '~760 United Nations Plaza',
            city: '~New York',
            state: '~NY',
            zip: '~10017',
            country: '~USA',
        },
    }

    put '/user/' << @vars[:user]['email'], request_data.to_json
    last_response.status.should == 200
    last_response.body.nil?.should be_false

    @vars[:user] = user = JSON.parse(last_response.body)
    user['password'].should == request_data[:password]
  end

  it 'deletes a user' do
    delete '/user/' << @vars[:user]['email']
    last_response.status.should == 200
  end
end

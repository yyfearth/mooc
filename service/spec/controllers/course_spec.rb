require_relative '../spec_helper'

describe 'Course API' do

  before :all do
    @vars = {}
  end

  it 'creates a course' do
    request_data = {
        name: ''
    }

    post '/course', request_data.to_json
    last_response.status.should == 201
    last_response.body.nil?.should be_false
    @vars[:course] = JSON.parse(last_response.body)
  end

  it 'gets a course' do
    get '/course/' << @vars[:course]['email']
    last_response.status.should == 200
  end

  it 'updates a course' do
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

    put '/course/' << @vars[:course]['email'], request_data.to_json
    last_response.status.should == 200
    last_response.body.nil?.should be_false

    @vars[:course] = course = JSON.parse(last_response.body)
    course['password'].should == request_data[:password]
  end

  it 'deletes a course' do
    delete '/course/' << @vars[:course]['email']
    last_response.status.should == 200
  end
end

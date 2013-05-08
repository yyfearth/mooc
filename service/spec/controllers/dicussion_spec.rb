require_relative '../spec_helper'

describe 'Discussion API' do

  before :all do
    @vars = {}
  end

  it 'creates a discussion' do
    request_data = {
        title: 'Test Discussion',
        created_by: 'test@test.com'
    }

    post '/discussion', request_data.to_json
    last_response.status.should == 201

    @vars[:discussion] = response_data = JSON.parse last_response.body

    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  it 'gets a discussion' do
    request_data = {
        title: 'Test Discussion',
        created_by: 'test@test.com'
    }

    get '/discussion/' << @vars[:discussion]['id'], request_data.to_json
    last_response.status.should == 200

    response_data = JSON.parse last_response.body
    response_data['title'].should == request_data[:title]
    response_data['created_by'].should == request_data[:created_by]
  end

  it 'update a discussion' do
    request_data = {
        title: 'Updated Discussion',
        created_by: 'updated@test.com'
    }

    put '/discussion/' << @vars[:discussion]['id'], request_data.to_json
    last_response.status.should == 200

    response_data = JSON.parse last_response.body
    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  it 'delete a discussion' do
    delete '/discussion/' << @vars[:discussion]['id']
    last_response.status.should == 200
  end
end

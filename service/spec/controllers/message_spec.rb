require_relative '../spec_helper'

describe 'Message API' do

  before :all do
    @vars = {}
    get '/discussions/all'
    response_data = JSON.parse last_response.body
    @discussion_id = response_data[0]['id']
  end

  it 'creates a message' do
    request_data = {
        title: 'Test title',
        content: 'Test message',
        created_by: 'test@test.com'
    }

    post '/discussion/' << @discussion_id << '/message', request_data.to_json
    last_response.status.should == 201

    @vars[:message] = response_data = JSON.parse last_response.body

    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  it 'gets a message' do
    get '/discussion/' << @discussion_id << '/message/' << @vars[:message]['id']
    last_response.status.should == 200

    request_data = {
        title: 'Test title',
        content: 'Test message',
        created_by: 'test@test.com'
    }

    response_data = JSON.parse last_response.body
    response_data['title'].should == request_data[:title]
    response_data['created_by'].should == request_data[:created_by]
  end

  it 'update a message' do
    request_data = {
        id: @vars[:message]['id'],
        discussion_id: @vars[:message]['discussion_id'],
        title: 'Updated title',
        content: 'Updated message',
        created_by: 'updated@test.com'
    }

    put '/discussion/' << @discussion_id << '/message/' << @vars[:message]['id'], request_data.to_json
    last_response.status == 200

    response_data = JSON.parse last_response.body
    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  it 'delete a message' do
    delete '/message/' << @vars[:message]['id']
    last_response.status == 200
  end
end

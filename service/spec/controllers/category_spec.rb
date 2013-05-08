require_relative '../spec_helper'

describe 'Category API' do

  before :all do
    @vars = {}
  end

  it 'creates a category' do
    request_data = {
        name: random_text(8),
    }

    post '/category', request_data.to_json
    @vars[:category] = category = JSON.parse(last_response.body)
    puts category['message'] unless category['error'].nil?

    last_response.status.should == 201
    last_response.body.nil?.should be_false
    category['id'].nil?.should be_false
  end

  it 'gets a category' do
    get '/category/' << @vars[:category]['id']
    @vars[:category] = category = JSON.parse(last_response.body)
    puts category['message'] unless category['error'].nil?

    last_response.status.should == 200
  end

  it 'updates a category' do
    request_data = {
        id: @vars[:category]['id'],
        name: random_text(8),
    }

    put '/category/' << request_data[:id], request_data.to_json
    @vars[:category] = category = JSON.parse(last_response.body)
    puts category['message'] unless category['error'].nil?

    last_response.status.should == 200
    last_response.body.nil?.should be_false

    category['name'].should == request_data[:name]
  end

  it 'deletes a category' do
    delete '/category/' << @vars[:category]['id']
    @vars[:category] = category = JSON.parse(last_response.body)
    puts category['message'] unless category['error'].nil?
    last_response.status.should == 200
  end
end

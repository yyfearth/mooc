require_relative '../spec_helper'

describe 'Announcement API' do

  before :all do
    @vars = {}
  end

  it 'creates a announcement' do
    request_data = {
        title: random_text(16),
        content: random_text(20),
        course_id: random_id,
        created_by: random_email,
    }

    post '/announcement', request_data.to_json
    @vars[:announcement] = announcement = JSON.parse(last_response.body)
    puts announcement['message'] unless announcement['error'].nil?

    last_response.status.should == 201
    last_response.body.nil?.should be_false
    announcement['id'].nil?.should be_false
  end

  it 'gets a announcement' do
    get '/announcement/' << @vars[:announcement]['id']
    @vars[:announcement] = announcement = JSON.parse(last_response.body)
    puts announcement['message'] unless announcement['error'].nil?

    last_response.status.should == 200
  end

  it 'updates a announcement' do
    request_data = {
        id: @vars[:announcement]['id'],
        title: random_text(16),
        content: random_text(20),
        course_id: random_id,
        created_by: random_email,
    }

    put '/announcement/' << request_data[:id], request_data.to_json
    @vars[:announcement] = announcement = JSON.parse(last_response.body)
    puts announcement['message'] unless announcement['error'].nil?

    last_response.status.should == 200
    last_response.body.nil?.should be_false

    announcement['title'].should == request_data[:title]
  end

  it 'deletes a announcement' do
    delete '/announcement/' << @vars[:announcement]['id']
    @vars[:announcement] = announcement = JSON.parse(last_response.body)
    puts announcement['message'] unless announcement['error'].nil?
    last_response.status.should == 200
  end
end

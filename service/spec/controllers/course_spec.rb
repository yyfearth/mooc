require_relative '../spec_helper'

describe 'Course API' do

  before :all do
    @vars = {}
  end

  it 'creates a course' do
    request_data = {
        title: random_text(16),
        description: 'The New Course',
        attachments: [],
        category_id: random_id,
        participants: [
            {
                email: 'instructer@test.com',
                role: 'instructer',
                status: 'drunk',
            },
            {
                email: 'student@test.com',
                role: 'student',
                status: 'cooked',
            },
        ],
        created_by: 'instructer@test.com',
        updated_by: 'instructer@test.com',
    }

    post '/course', request_data.to_json
    @vars[:course] = course = JSON.parse(last_response.body)
    puts course['message'] unless course['error'].nil?

    last_response.status.should == 201
    last_response.body.nil?.should be_false
    course['id'].nil?.should be_false
  end

  it 'gets a course' do
    get '/course/' << @vars[:course]['id']

    last_response.status.should == 200
  end

  it 'updates a course' do
    request_data = {
        id: @vars[:course]['id'],
        title: random_text(16),
        description: '~update Course',
        attachments: [],
        category_id: '18694174d09cd1bc80000260',
        participants: [],
        created_by: 'instructer2@test.com',
        updated_by: 'instructer2@test.com',
    }

    put '/course/' << request_data[:id], request_data.to_json
    @vars[:course] = course = JSON.parse(last_response.body)
    puts course['message'] unless course['error'].nil?

    last_response.status.should == 200
    last_response.body.nil?.should be_false

    course['name'].should == request_data[:name]
  end

  it 'deletes a course' do
    delete '/course/' << @vars[:course]['id']
    @vars[:course] = course = JSON.parse(last_response.body)
    puts course['message'] unless course['error'].nil?

    last_response.status.should == 200
  end
end

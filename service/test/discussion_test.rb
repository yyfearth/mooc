require 'test-unit'
require 'rack/test'
require_relative '../app'

class DiscussionTest < Test::Unit::TestCase
  include Rack::Test::Methods

  # It turns out that when Rake does the CRUD, it uses this method to get the application.
  def app
    App
  end

  class << self
    def startup
    end

    def shutdown
    end
  end

  def setup
  end

  def cleanup
  end

  def teardown
  end

  def test_1
    get '/discussions/all'
    p last_response
  end

  def test_create
    request_data = {
        title: 'Test Discussion',
        created_by: 'test@test.com',
    }

    json = request_data.to_json
    post('/discussion', json)
    assert last_response.status == 201

    @discussion = response_data = JSON.parse(last_response.body)

    assert_not_nil (/[\w\d]/ =~ response_data['id'])
  end

  def test_get
    request_data = {
        title: 'Test Discussion',
        created_by: 'test@test.com'
    }

    get('/discussion/' << @discussion['id'], request_data.to_json)
    last_response.status == 200

    response_data = JSON.parse(last_response.body)
    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  def test_update
    request_data = {
        title: 'Updated Discussion',
        created_by: 'updated@test.com'
    }

    put('/discussion/' << @discussion['id'], request_data.to_json)
    last_response.status == 200

    response_data = JSON.parse(last_response.body)
    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end

  def test_delete
    delete('/discussion/')
    last_response.status == 200

    response_data = JSON.parse(last_response.body)
    (/[\w\d]/ =~ response_data['id']).nil?.should be_false
  end
end


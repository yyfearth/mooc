require './spec/spec_helper'

describe 'UserController' do
  include Rack::Test::Methods

  def app
    App
  end

  it 'should return json' do
    get '/users'
    puts last_response.body
    last_response.should be_ok
  end
end

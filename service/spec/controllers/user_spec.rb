require File.dirname(__FILE__) + '/../spec_helper'

require './app'

describe 'controller' do
  include Rack::Test::Methods

  def app
    @app ||= App
  end

  it 'should return json' do
    get '/users'
    last_response.should be_ok
  end
end

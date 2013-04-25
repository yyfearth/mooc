require File.dirname(__FILE__) + '/../spec_helper'

require "#{root_path}/../init"

describe 'controller' do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  it 'should return json' do
    get '/users'
    last_response.should be_ok
  end
end

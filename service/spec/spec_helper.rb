require 'rack/test'
require_relative '../app'

#set :environment, :test

def app
  App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

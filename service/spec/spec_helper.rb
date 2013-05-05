require 'rspec'
require 'rack/test'
require './app'

def app
  App
end

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

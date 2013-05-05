require 'rack/test'
require_relative '../app'

# It turns out that when Rake does the CRUD, it uses this method to get the application.
def app
  App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

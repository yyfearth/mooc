require 'rack/test'
require_relative '../app'

# It turns out that when Rake does the CRUD, it uses this method to get the application.
def app
  App
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

LOWER_ALPHABETS = ('a'..'z').to_a
UPPER_ALPHABETS = ('A'..'Z').to_a
ALPHABETS = LOWER_ALPHABETS + UPPER_ALPHABETS
NUMBERS = ('0'..'9').to_a
CHARACTERS = ALPHABETS + NUMBERS

def random_text(length)
  (0...length).map { (ALPHABETS + [' '])[rand(ALPHABETS.size + 1)] }.join
end

def random_hex(length)
  (0...length).map { ('a'..'z').to_a[rand(26)] }.join
end

def random_id
  random_hex(24)
end

def random_email
  random_text(8) << '@test.com'
end

require './spec/spec_helper'

describe 'UserController' do
  it 'should return json' do
    get '/users'
    puts last_response.body
    last_response.should be_ok
  end
end

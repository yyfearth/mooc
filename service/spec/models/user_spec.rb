require './app'

describe User do

  it 'should create a new user' do
    User.new(
        email: 'test@test.com',
        first_name: 'James',
        last_name: 'Smith',
    ).should_not be_nil
  end

  it 'should create a new user with address' do
    user = User.new(
        email: 'test@test.com',
        first_name: 'James',
        last_name: 'Smith',
        address: Address.new(
            city: 'San Jose',
            state: 'CA'
        )
    )
    user.should_not(be_nil) and user.address.should_not be_nil
  end
end

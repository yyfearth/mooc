before do
  content_type 'application/json;charset=utf-8'
end

# get a user by email (id)
get '/user/:email' do
  email = params :email
  user = User.find_by_id email
  user.to_json
end

# search users
get '/users' do
  q = SearchParams.new params
  users = User.where(q.where).order(q.order_by).offset(q.offset).limit(q.limit)
  users.to_json
end

# create a new user
post '/users' do
  json = JSON.parse request.body.read
  #user = User.create json
  #user.password = json['password'] # for protected
  #user.save!
  email = json['email']
  if User.find_by_id email
    status 409
    Error.create 'EMAIL_DUPLICATED', "User with email #{email} already exists"
  else
    user = User.create! json
    status 201 # created
    headers 'Location' => url('/user/' + user.email)
    user.to_json
  end
end

# create/update a user
put '/user/:email' do
  json = JSON.parse request.body.read
  email = params :email
  if json['email'] != email
    status 400
    Error.create 'EMAIL_NOT_MATCH', "The emails in the URL #{email} and JSON #{json['email']} are not matched"
  else
    status 201 unless User.find_by_id email
    user = User.create! json
    user.to_json
  end
end

# delete a user by email (id)
delete '/user/:email' do
  email = params :email
  user = User.find_by_id email
  if user
    user.destroy
    OK.create "User with email #{email} deleted"
  else
    status 404
    Error.create 'USER_NOT_FOUND', "User with email #{email} not found"
  end
end

# use for debug only

# get all users
get '/users/all' do
  User.all.to_json
end

# delete all users
delete '/users/all' do
  User.destroy_all
  OK.create 'All users cleared'
end


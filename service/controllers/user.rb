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
  offset = params[:offset] || 0
  limit = params[:limit] || 20
  order_by = params[:order_by] || :created_by.desc
  created_from = params[:created_from]
  created_to = params[:created_to]
  updated_from = params[:updated_from]
  updated_to = params[:updated_to]
  q = {}
  q[:created_at.gte] = Time.parse(created_from) if created_from
  q[:created_at.lte] = Time.parse(created_to) if created_to
  q[:updated_at.gte] = Time.parse(updated_from) if updated_from
  q[:updated_at.lte] = Time.parse(updated_to) if updated_to
  puts q
  users = User.where(q).order(order_by).offset(offset).limit(limit)
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

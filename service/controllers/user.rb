class UserController < Controller

  # get a user by email (id)
  get '/user/:email' do
    email = params[:email]
    user = User.find_by_id email
    if user
      ok user
    else
      not_found 'USER_NOT_FOUND', "User with email #{email} is not found"
    end
  end

  # search users
  get '/users' do
    users = do_search User, params
    ok users
  end

  # check user credentials via basic auth
  get '/user/validation' do
    auth = Rack::Auth::Basic::Request.new(request.env)
    if auth.provided? and auth.basic? and auth.credentials
      email = auth.credentials[0]
      user = User.find_by_id email
      if user and auth.credentials[1] == user.password
        ok 'User validation passed'
      end
    end
    headers['WWW-Authenticate'] = 'Basic realm="User Validation"'
    err 401, 'NOT_AUTHORIZED', 'User validation failed'
  end

  # create a new user
  post '/users' do
    json = JSON.parse request.body.read
    email = json['email']
    if email.to_s.empty?
      bad_request 'EMAIL_EMPTY', 'Email is required'
    elsif User.find_by_id email
      conflict 'EMAIL_DUPLICATED', "User with email #{email} already exists"
    else
      user = User.create! json
      created user
    end
  end

  # create/update a user
  put '/user/:email' do
    json = JSON.parse request.body.read
    email = params[:email]
    if json['email'] != email
      bad_request 'EMAIL_NOT_MATCH', "The emails in the URL #{email} and JSON #{json['email']} are not matched"
    elsif User.find_by_id email # exists
      json.delete 'password'
      user = User.update email, json
      ok user
    else # not exist
      user = User.create! json
      created user
    end
  end

  # update password
  put '/user/:email/password' do
    password = request.body.read
    email = params[:email]
    if email.to_s.empty?
      bad_request 'EMAIL_EMPTY', 'Email is required'
    elsif password.to_s.empty?
      bad_request 'PASSWORD_EMPTY', 'Password in body is required'
    else
      User.update email, :password => password
      ok 'Password updated'
    end
  end

  # delete a user by email (id)
  delete '/user/:email' do
    email = params[:email]
    user = User.find_by_id email
    if user
      user.destroy
      ok "User with email #{email} deleted"
    else
      not_found 'USER_NOT_FOUND', "User with email #{email} not found"
    end
  end

  # FOR DEBUG ONLY

  # get all users
  get '/users/all' do
    ok User.all
  end

  # delete all users
  delete '/users/all' do
    User.destroy_all
    ok 'All users cleared'
  end

  run!

end

class UserController < Controller

  USER_EMAIL_URL = '/user/:email'
  USERS_URL = '/users'
  ALL_USERS_URL = '/users/all'
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  helpers do

    def user_not_found?(email, user)
      not_found 'USER_NOT_FOUND', "User with email #{email} is not found" if user.nil?
    end

    def duplicated?(email)
      conflict 'EMAIL_DUPLICATED', "User with email #{email} already exists" if User.find email
    end

    def invalid_email?(email)
      if email.to_s.empty?
        bad_request 'EMPTY_EMAIL', 'Email is required'
      elsif (EMAIL_REGEX =~ email).nil?
        bad_request 'INVALID_EMAIL', 'Email is invalid'
      end
    end

    def email_not_matched?(params, json)
      url_email = params[:email]
      json_email = json['email']
      bad_request 'EMAIL_NOT_MATCH', "Email in URL is not matched #{url_email} != #{json_email}" if url_email != json_email
    end

  end

  before USER_EMAIL_URL do
    invalid_email? params[:email]
  end

  # get a user by email (id)
  get USER_EMAIL_URL do
    email = params[:email]
    user = User.find email
    user_not_found? email, user
    ok user
  end

  # search users
  get USERS_URL do
    ok do_search User, params
  end

  # check user credentials via basic auth
  get '/user/validation' do
    auth = Rack::Auth::Basic::Request.new(request.env)
    if auth.provided? && auth.basic? && auth.credentials
      email = auth.credentials[0]
      user = User.find email
      if user && auth.credentials[1] == user.password
        ok 'User validation passed'
      end
    end
    headers['WWW-Authenticate'] = 'Basic realm="User Validation"'
    err 401, 'NOT_AUTHORIZED', 'User validation failed'
  end

  # create a new user
  post USERS_URL do
    json = JSON.parse request.body.read
    email = json['email']
    invalid_email? email
    duplicated? email
    created User.create! json
  end

  # create/update a user
  put USER_EMAIL_URL do
    json = JSON.parse request.body.read
    email_not_matched? params, json
    email = json['email']
    if User.find email # exists
      ok User.update email, json
    else # not exist
      created User.create! json
    end
  end

  # delete a user by email (id)
  delete USER_EMAIL_URL do
    email = params[:email]
    user = User.find email
    user_not_found? email, user
    user.destroy
    ok "User with email #{email} deleted"
  end

  # FOR DEBUG ONLY

  # get all users
  get ALL_USERS_URL do
    ok User.all
  end

  # delete all users
  delete ALL_USERS_URL do
    User.destroy_all
    ok 'All users cleared'
  end

  run!

end

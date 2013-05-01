class UserController < EntityController

  USER_EMAIL_URL = '/user/:email'
  USERS_URL = '/users'
  ALL_USERS_URL = '/users/all'
  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  helpers do

    def user_not_found?(user = @user, email = @email)
      @entity_name = User.name
      entity_not_found? user, email
    end

    def invalid_email?(email = @email)
      if email.to_s.blank?
        bad_request 'EMPTY_EMAIL', 'Email is required'
      elsif (EMAIL_REGEX =~ email).nil?
        bad_request 'INVALID_EMAIL', "Email '#{email}' is invalid"
      end
    end

    def email_not_matched?(json)
      email = @email || param[:email]
      json_email = json['email']
      bad_request 'EMAIL_NOT_MATCH', "Email in URL is not matched '#{email}' != '#{json_email}'" if json_email && email != json_email
    end

  end

  before USER_EMAIL_URL do
    @email = params[:email]
    invalid_email?
  end

  # get a user by email (id)
  get USER_EMAIL_URL do
    @user = User.find @email
    user_not_found?
    ok @user
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
    @email = json['email']
    invalid_email?
    begin
      created User.create! json
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # create/update a user
  put USER_EMAIL_URL do
    json = JSON.parse request.body.read
    email_not_matched? json
    begin
      if User.find @email # exists
        ok User.update @email, json
      else # not exist
        created User.create! json
      end
    rescue MongoMapper::DocumentNotValid => e
      invalid_entity! e
    end
  end

  # delete a user by email (id)
  delete USER_EMAIL_URL do
    @user = User.find @email
    user_not_found?
    @user.destroy
    ok "User '#{@email}' deleted"
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

end

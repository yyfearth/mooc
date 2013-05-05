class User < ActiveResource::Base
  self.site = 'http://aws.myyapps.com/mooc/api/'
  self.element_name = 'user'	#if get|put|delete, then element_path
  self.collection_name = 'users'	#if post, then collection_path
  attr_accessor :remember_me
  attr_accessor :current_password
  #validates_confirmation_of :password

  class << self
    def element_path(id, prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{element_name}/#{id}#{query_string(query_options)}"
    end

    def collection_path(prefix_options = {}, query_options = nil)
      prefix_options, query_options = split_options(prefix_options) if query_options.nil?
      "#{prefix(prefix_options)}#{collection_name}#{query_string(query_options)}"
    end
  end

def to_json(options={})
  self.attributes.to_json(options)
end

# Log a user in.
def login!(session)
  session[:user_id] = email
end

def self.logout!(session, cookies)
  session[:user_id] = nil
  cookies.delete(:authorization_token)
end

# Clear the password (typically to suppress its display in a view).
def clear_password!
  self.password = nil
  self.password_confirmation = nil
  self.current_password = nil
end

def remember_me?
  remember_me == "1"
end

def remember!(cookies)
  cookie_expiration = 10.years.from_now
  cookies[:remember_me] = { :value   => "1",
                            :expires => cookie_expiration }
  self.authorization_token = unique_identifier
  save!
  cookies[:authorization_token] = { :value   => authorization_token,
                                    :expires => cookie_expiration }
end

def forget!(cookies)
  cookies.delete(:remember_me)
  cookies.delete(:authorization_token)
end
end


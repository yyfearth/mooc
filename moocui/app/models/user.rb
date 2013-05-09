class User < ActiveResource::Base
  self.element_name = 'user'
  self.collection_name = 'users'
  attr_accessor :remember_me
  attr_accessor :current_password

  # Log a user in.
  def login!(session)
    session[:usr] = self
  end

  def self.logout!(session, cookies)
    session[:usr] = nil
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
    cookies[:remember_me] = {:value => "1",
                             :expires => cookie_expiration}
    self.authorization_token = unique_identifier
    save!
    cookies[:authorization_token] = {:value => authorization_token,
                                     :expires => cookie_expiration}
  end

  def forget!(cookies)
    cookies.delete(:remember_me)
    cookies.delete(:authorization_token)
  end
end

class UsersController < ApplicationController
  include UsersHelper

  def index
    user=session[:usr]

    if user.nil?
      redirect_to :action => 'login'
    else
      @user = user
      @enroll = Course.find(:all, :params => {:participant_email => user.email})
      p @enroll
    end
  end

  def logout
    User.logout!(session, cookies)
    flash[:notice] = 'Logged out'
    redirect_to :action => 'login'
  end

  def register
    @title = 'Register'
    if param_posted?(:user)
      p params[:user]
      user = params[:user]
      if !user[:password].empty? && user[:password] == user[:confirm_password]
        user[:password] = Digest::SHA1.hexdigest(user[:password])
        user.delete(:confirm_password)
        @user = User.new(user)
        if @user.save
          @user.login!(session)
          flash[:notice] = "User #{@user.email} created!"
          redirect_to :action => 'login'
        else
          @user.clear_password!
        end
      else
        flash[:notice]= 'Confirm password does not match the entered password'
        respond_to do |format|
          format.html
        end
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def login
    @title = 'Log in to MOOC'
    if request.get?
      @user = User.new(email: '', remember_me: 1)
    elsif param_posted?(:user) #uses form_for :user => form_for uses post method and get|put|delete uses params[:id]
      @user = User.new(params[:user])
      @users = User.find(@user.email)
      user = User.find(@user.email)
      p @users.email
      p user
      p params[:user][:password]
      p Digest::SHA1.hexdigest(params[:user][:password])
      if user && user.password==Digest::SHA1.hexdigest(params[:user][:password])
        user.login!(session)
        if @user.remember_me?
          user.remember!(cookies)
        else
          user.forget!(cookies)
        end
        flash[:notice] = "User #{user.email} logged in!"
        redirect_to_forwarding_url
      else
        @user.clear_password!
        flash[:notice] = 'Invalid User name/password combination'
      end
    end


    #even if nothing is added it will fetch the page
    #redirect_to :action => "login" 	#calls the get method
    #respond_to do |format|
    #format.html # index.rhtml   //just display the file once and not call the same action recursively
    #format.xml { render :xml => @posts.to_xml }
    #end

    #elsif param_posted?
    #   redirect_to :action => "index", :controller => "courses"
    #end
  end

  def redirect_to_forwarding_url
    if request.post?
      redirect_to :action => 'index'
    end
  end

  def param_posted?(symbol)
    request.post? and params[symbol]
  end

  def search
  end

end

class UsersController < ApplicationController
  include UsersHelper

  def index
    user=session[:usr]
    @usr = User.find(user.email)
    @blog= Discussion.new

    p user.email
    if user.nil?
      redirect_to :action => 'login'
    else
      @user=user
      #@pa = Course.find(:all, :params => {:'participants.email' => user.email})

      #Course.find(:all, :params => {:'participants.email' => 'test2@test.com'}) => goes directly to the database and finds the 			following based on participans.email  :::::
      # [#<Course:0xae7e99c @attributes={"category_id"=>"test", "created_at"=>"2013-05-05T02:32:35Z", "created_by"=>"test@test.com", 			"description"=>"A test Course has more participants", "id"=>"5185c4c3a726764357000004", "participants"=>[			 			#<Course::Participant:0xa6a7804 	 @attributes={"email"=>"test2@test.com", "role"=>"student", "status"=>"ENROLLED"}, 			@prefix_options={}, @persisted=false>, 		  	  #<Course::Participant:0xa6a723c @attributes={"email"=>"abc@test.com", 		"role"=>"student", "status"=>"DROPPED"}, @prefix_options={}, 		@persisted=false>, #<Course::Participant:0xa6a6f80 			@attributes={"email"=>"test@test.com", "role"=>"OWNER", "status"=>"ENROLLED"}, 		@prefix_options={}, @persisted=false>], 		"status"=>"OPENED", "title"=>"Test", "updated_at"=>"2013-05-05T02:32:35Z"}, @prefix_options={}, 	@persisted=true>]

      @enroll= Course.find(:all, :params => {:participant_email => user.email})
      p @enroll
      #Course.find(:all, :params => {:participant_email => user.email}) => goes to the framework and executes the get method to search 			for courses in the DB that takes only :participant_email as parameter since it is mapped to the search method in course.rb inside 			the Sinatra code.
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

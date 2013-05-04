class UserController < ApplicationController
include UserHelper  
def index
	redirect_to :action => "login"
  end


  def register
	@title = "Register"
	if param_posted?
		flash[:notice] = " ........."
		redirect_to_forwarding_url
	else
		flash[:notice] = "hello man"
		respond_to do |format|
	        format.html # index.rhtml
        	#format.xml { render :xml => @posts.to_xml }
		end
	        
	end
  	
  end

def create
end

def login
  @title = "Log in to MOOC"
  if request.get?
    flash[:notice] = "Request is a get request.."


    #even if nothing is added it will fetch the page
    #redirect_to :action => "login" 	#calls the get method
    #respond_to do |format|
	 #format.html # index.rhtml   //just display the file once and not call the same action recursively
         #format.xml { render :xml => @posts.to_xml }
    #end


  elsif param_posted?
      redirect_to :action => "index", :controller => "course"
  end
end

def redirect_to_forwarding_url
if request.post?
	redirect_to :action => "login" 	#calls the get method
else

redirect_to :action => "index", :controller => "course"

end
end

def param_posted?
flash[:notice] = "hello"
  request.post?
end

def logout
  flash[:notice] = "Logged out"
  redirect_to_forwarding_url
end



  def search
  end
end

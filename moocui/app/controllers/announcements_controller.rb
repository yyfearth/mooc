class AnnouncementsController < ApplicationController
  def index
   @course = Course.find(:all)
   @announcements = Announcement.find(:all)
   @x = 0
   user=session[:usr]
   p request.post?
   if request.post?
        @course_id=params[:course_id]
        @x = 1
	p @x
	p @course[0]
 	p @announcements[0].title.downcase
   end
  end

 def display
	id = params[:id]
	p id
	@contents=Announcement.find(:all, :params => {:id => id})
	(0...@contents.length).each do |i|
	  if @contents[i].id == id
	   p @contents[i]
	   @content=@contents[i]
	   break
	  end
	end
 end


  def create
  @user=session[:usr]
  p @user.email
  announcement=params[:announcement]
   @courses = Course.find(:all)
   if request.post?
    if !announcement[:title].empty? and !announcement[:content].empty?
      @announcement = Announcement.new(announcement)
      @announcement.created_by=@user.email
        
       if @announcement.save
        flash[:notice] = "Category #{@announcement.title} created!"
 	#render :json => category
        redirect_to :action => "index", :controller => "users"
       end
    else
     respond_to do |format|
	format.html
     end
    end
  end
 end
  

  def add
  end

  def search
  end
end

class CoursesController < ApplicationController
  def index
    user = session[:usr]
    if user.nil?
      redirect_to :action => "login", :controller => "users"
    else
      if params[:id].nil?
        redirect_to :action => "search"
      else
        p params[:id]
        user = session[:usr]
        @course = Course.find(params[:id])
        @courses = Course.find(@course.id)
        p @courses.participants
        @usr = @course.participants
        p @usr[0].status
        p user
        p @course.description
      end
    end
  end

  def search
    if params[:q]
      query = params[:q]
      p query
      begin
        # First find the course hits...
        @courses = Course.find(:all, :params => {:q => query})
        p @courses
        @user = session[:usr]
        #p @courses[0].id

        #@enroll= Course.find(:all, :params => {:participant_email => 'test@test.com'}  //used in users_controller

        #@courses.uniq!
        #@invalid=true
      end
    end
  end


  def delete
    @user=session[:usr]
    p @user.email
    @courses=Course.find(:all)
    (0...@courses.length).each do |i|
      p @courses[i].created_by
    end
    if !params[:id].nil?
      p params[:id]
      p Course.find(params[:id])
      course=Course.find(params[:id])
      course.destroy
      redirect_to :action => "index", :controller => "users"
    end
  end

  def create
    @user=session[:usr]
    @categories = Category.find(:all)
    p @user.email
    course=params[:course]
    if request.post?
      if !course[:title].empty? && !course[:description].empty?
        @cat = Course.find(:all)
        @cat.each do |ctgy|
          if ctgy.title == params[:course][:title]
		return
          end
        end
        p params['discussion']
	p params[:category_id]
	if params['discussion'] == '1'
        course[:created_by] = @user.email
          #@course = Course.new(course, :participants => [Participant.new(:email => @user.email)])
          @course = Course.new(course)
	  p @course.created_by
          if @course.save
		p @course
		@discussion = Discussion.new(:course_id => @course.id, :title => @course.title, :created_by => @user.email)
		@discussion.save
                redirect_to :action => "index", :controller => "users"
          end
       end
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def enroll
  end

end

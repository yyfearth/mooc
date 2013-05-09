class DiscussionsController < ApplicationController

  def index
    @posts = Discussion.find(:all)
    @user = session[:usr]
    @title = "Discussion Dashboard"
    @courses=Course.find(:all)
    p @posts
    respond_to do |format|
      format.html # index.rhtml
      format.json { render :json => @posts.to_json }
    end
  end

  def show
    @discussion = Discussion.find(params[:id])
    @title = @discussion.title
    respond_to do |format|
      format.html # show.rhtml
      format.json { render :json => @posts.to_json }
    end
  end

  def display
    id = params[:course_id]
    p id
    @contents = Discussion.find(:all, :params => {:course_id => id})
    (0...@contents.length).each do |i|
      if @contents[i].course_id == id
        p @contents[i]
        @content = @contents[i]
        break
      end
    end
  end



  def new
    #discussion= Discussion.new
    #@discussion=Discussion.new => throws error while retrieving new.html.erb form if table field like :title does not exist since the form       uses :discussion which points to @discussion and maps all the fields in the array like title,created_by if used with form variable.
    @title = "Add a new Discussion"
    @courses = Course.find(:all)
    @user=session[:usr]
    if request.post?
      p params[:discussion]
      @post = Discussion.new(params[:discussion])
      user = session[:usr]
      discussion=params[:discussion]
      @post.created_by=user.email
      @post.course_id=params[:discussion][:course_id]
      p @post
      if !discussion[:title].empty?
        if @post.save
          redirect_to :action => "index", :controller => "users"
        end
      else
        respond_to do |format|
          format.html
        end
      end
    end
  end

  def create
    p "inside create of Discussion_controller"
    @post = Discussion.new(params[:discussion])
    user = session[:usr]
    discussion=params[:discussion]
    @post.created_by=user.email
    @post.course_id=params[:discussion][:course_id]
    p @post.course_id
    if !discussion[:title].empty?
      if @post.save
        redirect_to :action => "index", :controller => "users"
      end
    else
      respond_to do |format|
        format.html
      end
    end
  end

  def destroy
    @post = Discussion.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.html { redirect_to discussions_url }
      format.json { head :ok }
    end
  end

  def add
  end

  def search
  end


end

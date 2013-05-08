class DiscussionsController < ApplicationController
  
  def index
   #@posts = Discussion.find(:all)
   @title = "Discussion Dashboard"
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

 def new
  @discussion = Discussion.new
  @title = "Add a new Discussion"
 end

 def create
  @post = Discussion.new(params[:discussion])
  respond_to do |format|
   if @blog << @post
     flash[:notice] = 'Post was successfully created.'
     format.html { redirect_to discussion_url(:id => @post) }
     format.json { head :created, :location => discussion_url(:id => @post) }
   else
     format.html { render :action => "new" }
     format.json { render :json => @post.errors.to_json }
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

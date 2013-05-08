class CategoriesController < ApplicationController
  def index
    @categories = Category.find(:all)
  end

  def create
    @user=session[:usr]
    p @user.email
    category=params[:category]


    if request.post?
      if !category[:name].empty?
        @cat = Category.find(:all)
        @cat.each do |ctgy|
          if ctgy.name == params[:category][:name]
            return
          end
        end
        @category = Category.new(category)
        @category.created_by=@user.email

        if @category.save
          flash[:notice] = "Category #{@category.name} created!"
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

  def search
  end

  def add
  end
end

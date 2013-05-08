class HomeController < ApplicationController
  def index
    @title = "Welcome to Project MOOC"
    respond_to do |format|
      format.html # index.html.slim
      format.json { render :json => @title }
    end
  end
end

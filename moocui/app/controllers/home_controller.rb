class HomeController < ApplicationController
  def index
    if session[:usr].to_s.empty?
      redirect_to controller: 'users', action: 'login'
    else
      redirect_to controller: 'users', action: 'index'
    end
  end
end

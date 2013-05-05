module ApplicationHelper
require 'string'
require 'object'

def nav_link(text, controller, action="index")
  link_to_unless_current text, :id => nil,
                               :action => action,
                               :controller => controller
end
# Return true if some user is logged in, false otherwise.
def logged_in?
  not session[:user_id].nil?
end

end

class Course < ActiveResource::Base
  self.element_name = 'course'
  self.collection_name = 'courses'
  attr_accessor :discussion_yes
  attr_accessor :discussion_no

  def custom_method_element_url(method_name, options = {})
    "#{self.class.prefix(prefix_options)}#{self.class.element_name}/#{id}/#{method_name}#{self.class.__send__(:query_string, options)}"
  end

end

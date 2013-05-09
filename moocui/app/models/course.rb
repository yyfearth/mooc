class Course < ActiveResource::Base
  self.element_name = 'course'
  self.collection_name = 'courses'
  attr_accessor :discussion_yes
  attr_accessor :discussion_no
end

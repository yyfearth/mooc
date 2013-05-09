require_relative 'base'

class Course < Entity
  self.element_name = 'course'
  self.collection_name = 'courses'
  attr_accessor :discussion_yes
  attr_accessor :discussion_no
end

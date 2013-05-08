require_relative 'base'

class Message < Entity
  belongs_to :discussion
  belongs_to :user
  self.element_name = 'message'
  self.collection_name = 'messages'
end

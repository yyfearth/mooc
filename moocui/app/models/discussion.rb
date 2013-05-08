require_relative 'base'

class Discussion < Entity
  # has_many :messages
  # belongs_to :user
  self.element_name = 'discussion'
  self.collection_name = 'discussions'
end

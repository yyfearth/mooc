class Discussion < ActiveResource::Base
  # has_many :messages
  # belongs_to :user
  self.element_name = 'discussion'
  self.collection_name = 'discussions'
end

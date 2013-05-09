class Announcement < ActiveResource::Base
  self.element_name = 'announcement'
  self.collection_name = 'announcements'
end

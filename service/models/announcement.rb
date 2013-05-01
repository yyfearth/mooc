class Announcement
  include MongoMapper::Document

  key :title, String, required: true
  key :content, String, required: true
  key :course_id, ObjectId
  key :created_by, String, required: true
  timestamps!

end

Announcement.ensure_index :title
Announcement.ensure_index :course_id

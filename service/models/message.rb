class Message
  include MongoMapper::Document

  belongs_to :Discussion

  key :title, String, {require: true}
  key :content, String, {require: true}
  key :discussion_id, String, {require: true}
  key :created_by, String, {require: true}
  timestamps!

  attr_protected :created_at
end

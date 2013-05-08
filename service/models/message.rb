class Message
  include MongoMapper::Document

  belongs_to :discussion

  key :title, String, {require: true}
  key :content, String, {require: true}
  #key :discussion_id, String, {require: true}
  key :created_by, String, {require: true}
  timestamps!

end

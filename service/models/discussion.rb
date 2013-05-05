class Discussion
  include MongoMapper::Document

  many :Message, {in: :message_ids}

  key :course_id, String
  key :title, String, {require: true}
  key :created_by, String, {require: true}
  key :message_ids, Array
  timestamps!
end


require 'time'

class Discussion
  include MongoMapper::Document

  many :Message, {in: :message_ids}

  key :course_id, String
  key :title, String, {require: true}
  key :created_by, String, {require: true}
  key :created_at, Time, {require: true, default: Time.now}
  key :message_ids, Array
  timestamps!

  attr_protected :created_at

  def to_s
    "#{title} #{message_ids.size}"
  end
end

class Message
  include MongoMapper::Document

  belongs_to :Discussion

  key :title, String, {require: true}
  key :content, String, {require: true}
  key :discussion_id, String, {require: true}
  key :created_by, String, {require: true}
  key :created_at, Time, {require: true, default: Time.now}
  key :update_at, Time, {require: true, default: Time.now}
  timestamps!

  attr_protected :created_at
end

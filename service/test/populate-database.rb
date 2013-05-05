require 'yaml'
require 'mongo_mapper'
require 'time'

# Initialize MongoMapper
config = YAML.load_file(File.dirname(__FILE__) << '/../config/mongo.yml')

environment = config['environment']

db_host = config[environment]['host']
db_port = config[environment]['port']
db_name = config[environment]['database']

MongoMapper.connection = Mongo::Connection.new(db_host, db_port)
MongoMapper.database = db_name
MongoMapper.connection.connect

require_relative '../models/message'
require_relative '../models/discussion'
require_relative '../models/course'

Course.destroy_all
Discussion.destroy_all
Message.destroy_all

3.times do |i|
  num_text = i.to_s
  course = Course.create({title: 'Course ' << num_text,
                          category_id: num_text,
                          description: 'Fake course ' << num_text,
                          created_by: 'user ' << num_text,
                         })
  p course

  discussion = Discussion.new({title: 'Test Discussion ' << num_text})
  discussion.course_id = course.id
  p discussion

  def get_random_text(length = 8)
    (0...length).map { (65+rand(26)).chr }.join
  end

  5.times do
    message = Message.create({title: get_random_text, content: get_random_text(20), discussion_id: discussion.id})
    discussion.message_ids << message.id
    p message
  end

  discussion.save
end

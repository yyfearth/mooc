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

require_relative '../models/user'
require_relative '../models/message'
require_relative '../models/discussion'
require_relative '../models/course'
require_relative '../models/category'
require_relative '../models/announcement'

User.destroy_all
Course.destroy_all
Category.destroy_all
Discussion.destroy_all
Message.destroy_all

@users = []
@categories = []

3.times do |i|
  num_text = i.to_s

  user = User.create({
                         email: 'test' << num_text << '@test.com',
                         password: 'a94a8fe5ccb19ba61c4c0873d391e987982fbbd3', # the SHA-1 hash of text 'test'
                         first_name: num_text,
                         last_name: 'test',
                         address: {
                             address: "#{num_text} United Nations Plaza",
                             city: 'New York',
                             state: 'NY',
                             zip: '10017',
                             country: 'USA',
                         },
                     })
  puts user
  @users << user

  category = Category.create({
                                 name: 'Category ' << num_text,
                             })
  puts category
  @categories << category
end

3.times do |i|
  num_text = i.to_s
  course = Course.create({
                             title: 'Course ' << num_text,
                             category_id: @categories[rand(@categories.size)].id,
                             description: 'Fake course ' << num_text,
                             created_by: @users[rand(@users.size)].email,
                         })
  puts course

  discussion = Discussion.new({title: 'Test Discussion ' << num_text})
  discussion.course_id = course.id
  discussion.created_by = @users[rand(@users.size)].email

  def get_random_text(length = 8)
    (0...length).map { (65 + rand(26)).chr }.join
  end

  5.times do
    message = Message.create({
                                 title: get_random_text,
                                 content: get_random_text(20),
                                 discussion_id: discussion.id,
                                 created_by: @users[rand(@users.size)].email,
                             })
    discussion.message_ids << message.id
    puts message.inspect
  end

  discussion.save
  puts discussion
end

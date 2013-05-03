require 'sinatra'
require 'json'
require 'yaml'
require 'mongo_mapper'

class App < Sinatra::Application

  configure do
    disable :sessions
    set :static, false

    # read the local configuration
    config = YAML.load_file File.dirname(__FILE__) + '/config/mongo.yml'

    environment = config['environment']

    db_host = config[environment]['host']
    db_port = config[environment]['port']
    db_name = config[environment]['database']


    # Configure the environment

    MongoMapper.connection = Mongo::Connection.new db_host, db_port
    MongoMapper.database = db_name

    MongoMapper.connection.connect

    helpers do
      include Rack::Utils
    end

  end

  before { content_type :json }
  not_found { error 404, {error: 'NOT_FOUND', message: 'Not found'}.to_json }

  # models
  require 'models/user'
  require 'models/category'
  require 'models/course'
  require 'models/announcement'
  require 'models/discussion'

  # controllers
  require 'controllers/base'
  require 'controllers/user'
  require 'controllers/category'
  require 'controllers/course'
  require 'controllers/announcement'
  require 'controllers/discussion'

  use UserController
  use CategoryController
  use CourseController
  use AnnouncementController
  use DiscussionController

  before { content_type :json }

end

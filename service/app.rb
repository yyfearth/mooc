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

  # models
  require_relative 'models/user'
  require_relative 'models/category'
  require_relative 'models/course'
  require_relative 'models/announcement'
  require_relative 'models/message'
  require_relative 'models/discussion'

  # controllers
  require_relative 'controllers/base'
  require_relative 'controllers/user'
  require_relative 'controllers/category'
  require_relative 'controllers/course'
  require_relative 'controllers/announcement'
  require_relative 'controllers/message'
  require_relative 'controllers/discussion'

end

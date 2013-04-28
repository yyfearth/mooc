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
  end

  require 'models/address'
  require 'models/user'
  require 'controllers/base'
  require 'controllers/user'
  require 'controllers/category'

end

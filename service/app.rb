require 'sinatra'
require 'json'
require 'yaml'
require 'mongo_mapper'

class App < Sinatra::Application

  configure do
    disable :sessions
    set :static, false
    set :protection, except: :ip_spoofing

    # read vcap service settings
    credentials = JSON.parse(ENV['VCAP_SERVICES'])['mongodb-2.0'].first['credentials'] rescue {}

    db_host = credentials['hostname'] rescue 'localhost'
    db_port = credentials['port'] rescue 27017
    db_name = credentials['db'] rescue 'mooc'
    db_username = credentials['username'] rescue ''
    db_password = credentials['password'] rescue ''

    db_conn = "mongodb://#{db_username}:#{db_password}@#{db_host}:#{db_port}/#{db_name}"

    # Configure the environment

    #MongoMapper.connection = Mongo::Connection.new(db_host, db_port)
    #MongoMapper.database = db_name
    #MongoMapper.database.authenticate db_username, db_password
    MongoMapper.connection = Mongo::Connection.from_uri(db_conn)
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

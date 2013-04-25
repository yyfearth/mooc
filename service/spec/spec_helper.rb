require 'rubygems'
require 'sinatra'
require 'rack/test'

def root_path
  File.expand_path '../', __FILE__
end

set :environment, :test

Dir["#{root_path}/app/models/*.rb"].each{ |file| require file }

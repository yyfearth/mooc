$: << File.expand_path(File.dirname(__FILE__))

require 'init'

set :run, false
set :environment, :production

run Sinatra::Application

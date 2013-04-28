$: << File.expand_path(File.dirname(__FILE__))

require 'app'

set :run, false
set :environment, :production

run App

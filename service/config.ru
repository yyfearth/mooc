$: << File.expand_path(File.dirname(__FILE__))

require 'app'

disable :protection

run App

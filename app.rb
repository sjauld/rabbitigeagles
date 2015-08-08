require 'rubygems'
require 'bundler'
ENV['RACK_ENV'] ||= 'development'
Bundler.require(:core, ENV['RACK_ENV'])

require './config/environments'
require './routes/init'

class Tip < ActiveRecord::Base
end

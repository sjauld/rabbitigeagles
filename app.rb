require 'rubygems'
require 'sinatra'
require 'haml'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

require 'routes/init'

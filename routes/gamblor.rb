class App < Sinatra::Base
  get '/' do
    @tips = Tip.order("matchtime DESC")
    puts @tips.inspect
    haml :index
  end

  get '/secure/add-tip' do
    haml :add_tip
  end

  post '/secure/add-tip' do
  end
end

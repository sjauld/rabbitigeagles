get '/' do
  @tips = Tip.order("matchtime DESC")
  puts @tips.inspect
  haml :index
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

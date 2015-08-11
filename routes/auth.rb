class App < Sinatra::Base
  configure do
    enable :sessions
  end

  helpers do
    def username
      session[:identity] ? session[:identity] : 'Hello stranger'
    end

    def where_user_came_from
      session[:previous_url] || '/'
    end
  end

  before %r{/secure/*} do
    unless session[:identity]
      session[:previous_url] = request.path
      @error = 'Sorry, you need to be logged in to visit ' + request.path
      halt haml :login_form
    end
  end

  get '/login/form' do
    haml :login_form
  end

  post '/login/attempt' do
    session[:identity] = params['username']
    redirect to where_user_came_from
  end

  get '/logout' do
    session.delete(:identity)
    redirect '/'
  end

end

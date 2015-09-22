class App < Sinatra::Base

  # Start by building the user
  before '/*' do
    build_user
  end

  # Routes requiring auth
  before '/tip/*' do
    authorize
  end

  # Unauthorized
  get '/401' do
    status 401
    haml :_401
  end

  not_found do
    status 404
    haml :_404
  end

  # login section
  get '/login' do
    @title = "log in"
    if session['email'].nil?
      redirect to('/auth/google_oauth2')
    else
      redirect to('/')
    end
  end

  get '/auth/google_oauth2/callback' do
    @title = "logged in"
    session.clear
    puts auth_hash.inspect
    auth_hash.info.each_pair do |k,v|
      session[k] = v
    end
    session['id'] = auth_hash['uid']
    puts session.inspect
    # add this user to the DB if they don't already exist
    flash[:notice] = "Login successful"
    redirect to('/')
  end

  get '/session' do
    puts session.inspect
    haml :session
  end

  get '/logout' do
    @title = "log out"
    session.clear
    redirect to('/')
  end

  def auth_hash
    request.env['omniauth.auth']
  end


  # helpers do
  #   def username
  #     session["email"] ? session["email"] : 'Hello stranger'
  #   end
  # end

end

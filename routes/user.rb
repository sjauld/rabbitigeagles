class App < Sinatra::Base

  # Delete user - only admin
  get '/user/:user/delete' do
    # TODO: admin rights within app
    if @user.email == ENV['ADMIN_USER']
      @deleted_user = User.where(id: params[:user]).first
      @deleted_user.delete
      flash[:notice] = "User #{@deleted_user.name} deleted!"
    else
      flash[:error] = "Sorry, you are not authorised to do that"
    end
    redirect to('/')
  end

  # User profile edit functionality
  get '/user/edit' do
    haml :'user/edit_user'
  end

  post '/user/edit' do
    @user.name        = params[:name]
    @user.first_name  = params[:first_name]
    @user.last_name   = params[:last_name]
    @user.image       = params[:image]
    @user.save
    flash[:notice] = 'User edited successfully'
    redirect to("/user/#{@user.id}")
  end

  # Manually add users who can't operate a computer
  get '/user/battleadd' do
    haml :'user/add_user'
  end

  post '/user/battleadd' do
    nice_params = escape_html_for_set(params)
    # Don't escape the image
    nice_params[:image] = params[:image]
    result = User.create(nice_params)
    redirect '/', notice: 'User created successfully!'
  end

  get '/user/:user' do
    @this_user = User.where(id: params[:user]).first
    if @this_user.nil?
      flash[:error] = "User #{params[:user]} does not exist"
      redirect to ('/')
    end
    @tips = @this_user.tips
    @stats = get_user_stats([@this_user]).first
    haml :'user/user_profile'
  end

end

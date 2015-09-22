module Auth
  def build_user
    if @user.nil? && !session['email'].nil?
      # @user = {}
      # @user['email']  = session['email']
      # Create the user if they don't exist
      if User.where(email: session['email']).count == 0
        User.create(
          name: session['name'],
          email: session['email'],
          first_name: session['first_name'],
          last_name: session['last_name'],
          image: session['image']
        )
        flash[:notice] = "New user successfully created for #{session[:email]}"
      end
      puts "email: #{session['email']}"
      @user = User.where(email: session['email']).first
      puts "User: #{@user.inspect}"
      # @user['name']   = session['name']
      # @user['id']     = session['id']
    # elsif ENV['RACK_ENV'] != 'production'
    #   @user['name']   = "Stuart Auld"
    #   @user['email']  = "sauld@cozero.com.au"
    #   @user['id']     = "sauld@cozero.com.au"
    end
    @user
  end

  def authorize
    if @user.nil? || @user.email.nil?
      redirect to('/401')
    end
  end

end

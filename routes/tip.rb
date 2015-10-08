class App < Sinatra::Base

  include Rack::Utils

  # Index page - show the current week's tips by default
  get '/' do
    puts flash.inspect
    @week = get_week_by_number(params[:week]) || current_week
    @tips = @week.tips.order("matchtime ASC").reject{|x| x.deleted}
    @results = get_results(@tips)
    haml :index
  end

  ###########################
  # Functionality to add tips
  ###########################
  get '/tip/add' do
    haml :add_tip
  end

  post '/tip/add' do
    nice_params = escape_html_for_set(params)
    # are we starting a new week?
    unless my_week = get_week_by_number(params[:tippingweek])
      my_week = Week.create(
        tippingweek: params[:tippingweek]
      )
    end
    nice_params[:week_id] = my_week.id

    puts nice_params.inspect
    # Which user to select?
    this_user = User.find(nice_params[:user_id]) rescue @user
    # Create the tip!
    result = this_user.tips.create(nice_params)
    # Email everyone
    if (/manly/i =~ params['description']).nil?
      pre = 'Don\'t forget to get your tips in'
    else
      pre = 'GO MANLY'
    end
    email_the_bastards("Week #{current_week.tippingweek}: #{this_user.first_name} has tipped #{nice_params['description']}",pre)

    # Redirect
    redirect '/', notice: "Tip added successfully!"
  end

  ############################
  # Functionality to edit tips
  ############################
  get '/tip/:id/edit' do
    @tip = Tip.find(params[:id])
    @tip_user = @tip.user
    if @tip.locked
      redirect "/tip/#{params[:id]}", error: 'Unable to edit tip - it is locked'
    else
      haml :edit_tip
    end
  end

  post '/tip/:id/edit' do
    nice_params = escape_html_for_set(params)
    tip = Tip.find(params[:id])
    begin
      nice_params[:week_id] = get_week_by_number(nice_params["tippingweek"]).id
    rescue
      redirect "/tip/#{params[:id]}", error: "Unable to edit tip - week #{nice_params["tippingweek"]} does not exist"
    end
    if tip.locked
      redirect "/tip/#{params[:id]}", error: 'Unable to edit tip - it is locked'
    else
      tip.update(nice_params.except('splat','captures'))
      redirect "/tip/#{params[:id]}", notice: 'Tip updated!'
    end
  end

  ###################
  # Update tip status
  ###################
  # Win
  get '/tip/:id/success' do
    update_result(params[:id],true)
    redirect back, notice: "Another win! <a href='/tip/#{params[:id]}/void'>(undo)</a>"
  end

  # Lose
  get '/tip/:id/smashed' do
    update_result(params[:id],false)
    redirect back, notice: "Bugger! <a href='/tip/#{params[:id]}/void'>(undo)</a>"
  end

  # Clear result
  get '/tip/:id/void' do
    update_result(params[:id],nil)
    redirect back, notice: "Result cleared."
  end

  # Lock tip
  get '/tip/:id/lock' do
    @tip = Tip.find(params[:id])
    if @tip.successful.nil?
      redirect back, notice: "No result yet!"
    else
      @tip.locked = true
      @tip.save
      # Check to see if we should perform some weekly calculations
      week=@tip.week
      if week.tips.reject{|t| t.locked}.count > 1
        #TODO: Do some weekly calculations in here
      end
      redirect back, notice: "Tip locked! <a href='/tip/#{params[:id]}/unlock'>(undo)</a>"
    end
  end

  # Unlock tip
  get '/tip/:id/unlock' do
    @tip = Tip.find(params[:id])
    @tip.locked = false
    @tip.save
    redirect back, notice: "Tip unlocked! <a href='/tip/#{params[:id]}/lock'>(undo)</a>"
  end

  # Delete tip
  get '/tip/:id/delete' do
    @tip = Tip.find(params[:id])
    unless @tip.locked
      @tip.deleted = true
      @tip.save
    end
    redirect '/', notice: "Tip deleted! <a href='/tip/#{params[:id]}/undelete'>(undo)</a>"
  end

  # Undelete tip
  get '/tip/:id/undelete' do
    @tip = Tip.find(params[:id])
    @tip.deleted = false
    @tip.save
    redirect '/', notice: "Tip undeleted! <a href='/tip/#{params[:id]}/delete'>(undo)</a>"
  end

  ##########
  # View tip
  get '/tip/:id' do
    @tip = Tip.find(params[:id])
    haml :single_tip
  end

  #######
  private
  #######

  def update_result(id,result)
    tip = Tip.find(id)
    unless tip.locked
      tip.successful = result
      tip.save
    end
  end

  def get_results(tips)
    successes = tips.select{|x| x.successful}
    possible = tips.reject{|x| x.successful == false}
    s_return = calculate_payout(successes)
    p_return = calculate_payout(possible)
    t_return = calculate_payout(tips)
    return {
      success: successes.count,
      possible: possible.count,
      total: tips.count,
      s_return: s_return,
      p_return: p_return,
      t_return: t_return
    }
  end

  # Calculates the total payout based on betting 3x, 4x, 5x and 6x combos
  # @param [Array,Tip] tips an array of tips to feed in
  #
  # Return [Float] the total payout
  def calculate_payout(tips)
    total = 0
    (3..6).each do |i|
      total += tips.map{|x| x.odds.to_f}.combination(i).to_a.map{|x| x.reduce(:*)}.reduce(:+).to_f
    end
    return total
  end

  def escape_html_for_set(things)
    new_things = {}
    things.each do |k,v|
      new_things[k] = escape_html(v).strip
    end
    return new_things
  end

end

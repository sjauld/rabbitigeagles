class App < Sinatra::Base

  include Rack::Utils

  get '/' do
    puts flash.inspect
    @week = params[:week] || current_week
    @tips = Tip.where(tippingweek: @week).order("matchtime ASC").reject{|x| x.deleted}
    @results = get_results(@tips)
    haml :index
  end

  get '/tip/add' do
    haml :add_tip
  end

  post '/tip/add' do
    nice_params = escape_html_for_set(params)
    puts nice_params.inspect
    result = @user.tips.create(nice_params)
    if (/manly/i =~ params['description']).nil?
      pre = 'Don\'t forget to get your tips in'
    else
      pre = 'GO MANLY'
    end
    email_the_bastards("Week #{current_week}: #{@user.first_name} has tipped #{nice_params['description']}",pre)
    redirect '/', notice: "Tip added successfully!"
  end

  # Tipping information
  get '/tip/:id/success' do
    update_result(params[:id],true)
    redirect back, notice: "Another win! <a href='/tip/#{params[:id]}/void'>(undo)</a>"
  end

  get '/tip/:id/smashed' do
    update_result(params[:id],false)
    redirect back, notice: "Bugger! <a href='/tip/#{params[:id]}/void'>(undo)</a>"
  end

  get '/tip/:id/void' do
    update_result(params[:id],nil)
    redirect back, notice: "Result cleared."
  end

  get '/tip/:id/lock' do
    @tip = get_tip(params[:id])
    if @tip.successful.nil?
      redirect back, notice: "No result yet!"
    else
      lock_tip(params[:id])
      redirect back, notice: "Tip locked! <a href='/tip/#{params[:id]}/unlock'>(undo)</a>"
    end
  end

  get '/tip/:id/unlock' do
    unlock_tip(params[:id])
    redirect back, notice: "Tip unlocked! <a href='/tip/#{params[:id]}/lock'>(undo)</a>"
  end

  get '/tip/:id/edit' do
    @tip = get_tip(params[:id])
    if @tip.locked
      redirect "/tip/#{params[:id]}", error: 'Unable to edit tip - it is locked'
    else
      haml :edit_tip
    end
  end

  post '/tip/:id/edit' do
    nice_params = escape_html_for_set(params)
    tip = get_tip(params[:id])
    if tip.locked
      redirect "/tip/#{params[:id]}", error: 'Unable to edit tip - it is locked'
    else
      tip.update(nice_params.except('splat','captures'))
      redirect "/tip/#{params[:id]}", notice: 'Tip updated!'
    end
  end

  get '/tip/:id' do
    @tip = get_tip(params[:id])
    haml :single_tip
  end

  get '/tip/:id/delete' do
    delete_tip(params[:id])
    redirect '/', notice: "Tip deleted! <a href='/tip/#{params[:id]}/undelete'>(undo)</a>"
  end

  get '/tip/:id/undelete' do
    undelete_tip(params[:id])
    redirect '/', notice: "Tip undeleted! <a href='/tip/#{params[:id]}/delete'>(undo)</a>"
  end

  #######
  private
  #######

  def get_tip(id)
    Tip.find_by(id: id)
  end

  def update_result(id,result)
    tip = get_tip(params[:id])
    unless tip.locked
      tip.successful = result
      tip.save
    end
  end

  def lock_tip(id)
    tip = get_tip(id)
    tip.locked = true
    tip.save
  end

  def unlock_tip(id)
    tip = get_tip(id)
    tip.locked = nil
    tip.save
  end

  def delete_tip(id)
    tip = get_tip(id)
    unless tip.locked
      tip.deleted = true
      tip.save
    end
  end

  def undelete_tip(id)
    tip = get_tip(id)
    tip.deleted = nil
    tip.save
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

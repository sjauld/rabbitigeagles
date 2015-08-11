class App < Sinatra::Base

  include Rack::Utils

  get '/' do
    @week = params[:week] || current_week
    @tips = Tip.where(tippingweek: @week).order("matchtime DESC").reject{|x| x.deleted}
    @results = get_results(@tips)
    haml :index
  end

  # Tipping information
  get '/tip/:id/success' do
    update_result(params[:id],true)
    redirect back
  end

  get '/tip/:id/smashed' do
    update_result(params[:id],false)
    redirect back
  end

  get '/tip/:id/void' do
    update_result(params[:id],nil)
    redirect back
  end

  get '/tip/:id/lock' do
    lock_tip(params[:id])
    redirect back
  end

  get '/tip/:id/unlock' do
    unlock_tip(params[:id])
    redirect back
  end

  get '/tip/:id/edit' do
    @tip = get_tip(params[:id])
    if @tip.locked
      'Unable to comply - this tip is locked'
    else
      haml :edit_tip
    end
  end

  post '/tip/:id/edit' do
    nice_params = escape_html_for_set(params)
    tip = get_tip(params[:id])
    if tip.locked
      'Unable to comply - this tip is locked'
    else
      tip.update(nice_params.except('splat','captures'))
      redirect "/tip/#{params[:id]}"
    end
  end

  get '/tip/:id' do
    @tip = get_tip(params[:id])
    haml :single_tip
  end

  get '/tip/:id/delete' do
    delete_tip(params[:id])
    redirect '/'
  end

  get '/tip/:id/undelete' do
    undelete_tip(params[:id])
    redirect '/'
  end

  # Add new tips
  get '/secure/add-tip' do
    haml :add_tip
  end

  post '/secure/add-tip' do
    nice_params = escape_html_for_set(params)
    result = Tip.create(nice_params)
    redirect "/tip/#{result.id}"
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

  def calculate_payout(tips)
    # we use all 6x, 5x, 4x and 3x combinations
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


  helpers do
    def current_week
      Tip.maximum(:tippingweek)
    end

    def current_tipping_week
      if Tip.where(tippingweek: current_week).reject{|x| x.locked || x.deleted}.count > 0
        current_week
      else
        current_week + 1
      end
    end
  end
end

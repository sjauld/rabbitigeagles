class App < Sinatra::Base
  get '/' do
    @tips = Tip.where(deleted:nil).order("matchtime DESC")
    puts @tips.inspect
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
    tip = get_tip(params[:id])
    if @tip.locked
      'Unable to comply - this tip is locked'
    else
      tip.update(params.except('splat','captures'))
      redirect "/tip/#{params[:id]}"
    end
  end

  get '/tip/:id' do
    @tips = [get_tip(params[:id])]
    haml :index
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
    result = Tip.create(params)
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

  def delete(id)
    tip = get_tip(id)
    unless tip.locked
      tip.deleted = true
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

  def undelete_tip(id)
    tip = get_tip(id)
    tip.deleted = nil
    tip.save
  end


  helpers do
    def current_week
      (( Date.today - Date.parse(ENV['TIPPING_START']) ) / 7).ceil
    end
  end
end

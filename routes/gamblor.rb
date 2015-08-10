class App < Sinatra::Base
  get '/' do
    @tips = Tip.order("matchtime DESC")
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

  get '/tip/:id/edit' do
    @tip = get_tip(params[:id])
    haml :edit_tip
  end

  post '/tip/:id/edit' do
    tip = get_tip(params[:id])
    tip.update(params.except('splat','captures'))
    redirect "/tip/#{params[:id]}"
  end

  get '/tip/:id' do
    @tip = get_tip(params[:id])
    haml :single_tip
  end

  delete '/tip/:id' do
    @tip = get_tip(params[:id])
    @tip.deleted = true
    @tip.save
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
    tip.successful = result
    tip.save
  end
end

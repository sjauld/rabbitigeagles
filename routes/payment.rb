class App < Sinatra::Base

  get '/payment/add' do
    haml :'/payment/add'
  end

  post '/payment/add' do
    the_user = User.find(params['user_id'])
    the_user.payments.create(amount: params[:payment])
    flash[:notice] = "Payment added!"
    redirect '/payment/'
  end

  get '/payment/' do
    @payment_data = all_users.map{|x| {name: x.name, payments: x.total_payments}}
    @recent_payments = Payment.last(10).reverse
    haml :'/payment/summary'
  end

end

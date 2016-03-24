class App < Sinatra::Base

  get '/payment/add' do
    haml :'/payment/add'
  end

  post '/payment/add' do
    if (amount = params[:payment].to_f) == 0
      flash[:error] = "Error: you have added a zero payment."
    else
      the_user = User.find(params['user_id'])
      the_user.payments.create(amount: amount)
      flash[:notice] = "Payment added!"
    end
    redirect '/payment/'
  end

  get '/payment/' do
    @payment_data = all_users.map{|x| {name: x.name, payments: x.total_payments}}
    @recent_payments = Payment.last(10).reverse
    haml :'/payment/summary'
  end

end

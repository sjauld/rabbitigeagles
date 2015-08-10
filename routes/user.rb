class App < Sinatra::Base
  get '/users/' do
    @user_stats = get_stats(select_all_users)
    haml :users
  end

  #######
  private
  #######
  def select_all_users
    Tip.uniq.pluck(:user)
  end

  def get_stats(users)
    results = []
    users.each do |user|
      user_tips = Tip.where(user: user).reject{|x| x.deleted}
      results << {
        user: user,
        successes: user_tips.select{|x| x.successful}.count,
        total: user_tips.reject{|x| x.successful == nil}.count
      }
    end
    results.sort{|x| x[:successes]}.reverse
  end

end

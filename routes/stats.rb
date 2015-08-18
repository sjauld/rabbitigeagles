class App < Sinatra::Base
  get '/users/' do
    @stats = get_user_stats(select_all_users)
    haml :user_stats
  end

  get '/sports/' do
    @stats = get_sport_stats(select_all_sports)
    haml :sport_stats
  end

  get '/users/:user' do
    @view = params[:user]
    @tips = get_tips_by_user(@view)
    haml :multi_tip
  end

  get '/sports/:sport' do
    @view = params[:sport]
    @tips = get_tips_by_sport(@view)
    haml :multi_tip
  end

  #######
  private
  #######
  def select_all_users
    Tip.uniq.pluck(:user)
  end

  def select_all_sports
    Tip.uniq.pluck(:sport)
  end

  def get_tips_by_user(user)
    Tip.where(user: user).reject{|x| x.deleted}
  end

  def get_tips_by_sport(sport)
    Tip.where(sport: sport).reject{|x| x.deleted}
  end

  def get_user_stats(users)
    results = []
    users.each do |user|
      user_tips = get_tips_by_user(user)
      unless user_tips == 0
        results << {
          user: user,
          successes: user_tips.select{|x| x.successful}.count,
          total: user_tips.reject{|x| x.successful == nil}.count
        }
      end
    end
    results.sort_by{|x| x[:successes]}.reverse
  end

  def get_sport_stats(sports)
    results = []
    sports.each do |sport|
      sport_tips = get_tips_by_sport(sport)
      unless sport_tips == 0
        puts "sport: #{sport} / #{sport_tips.inspect}"
        percent = sport_tips.select{|x| x.successful}.count * 100 / sport_tips.reject{|x| x.successful == nil}.count rescue -1
        results << {
          sport: sport,
          successes: sport_tips.select{|x| x.successful}.count,
          total: sport_tips.reject{|x| x.successful == nil}.count,
          percent: percent
        }
      end
    end
    results.sort_by{|x| x[:percent]}.reverse
  end

end

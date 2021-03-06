class App < Sinatra::Base
  get '/users/' do
    @stats = get_user_stats(User.all)
    haml :user_stats
  end

  get '/sports/' do
    @stats = get_sport_stats(select_all_sports)
    haml :sport_stats
  end

  get '/sports/:sport' do
    @view = params[:sport]
    @tips = get_tips_by_sport(@view)
    haml :multi_tip
  end

  #######
  private
  #######

  def select_all_sports
    Tip.uniq.pluck(:sport)
  end

  def get_tips_by_sport(sport)
    Tip.where(sport: sport).reject{|x| x.deleted}
  end

  def get_user_stats(users)
    results = []
    users.each do |user|
      user_tips = user.tips.reject{|x| x.deleted}
      unless user_tips.count == 0
        percent = user_tips.select{|x| x.successful}.count * 100 / user_tips.reject{|x| x.successful == nil}.count rescue -1
        results << {
          user: user,
          successes: user_tips.select{|x| x.successful}.count,
          total: user_tips.reject{|x| x.successful == nil}.count,
          percent: percent
        }
      end
    end
    results.sort_by{|x| x[:percent]}.reverse
  end

  def get_sport_stats(sports)
    results = []
    sports.each do |sport|
      sport_tips = get_tips_by_sport(sport)
      unless sport_tips.count == 0
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

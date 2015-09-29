module Gambling
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

  def current_tipping_status
    tips = Tip.where(tippingweek: current_week).reject{|x| x.deleted}
    if tips.count == 0
      return 'Noone has entered their tips yet. This makes Steve Menzies sad.'
    else
      return tips.map{|x| "#{x.user.nil? ? x.old_username : x.user.name}: #{x.description}"}.join("\n")
    end
  end

  def email_the_bastards(subject,pre)
    the_body = "#{pre}\n\nCurrent tips:-\n#{current_tipping_status}\n\n--\nTigersearabbit Tipping System"
    message = Mail.new do
      from    ENV['TIPPING_FROM_ADDRESS']
      to      ENV['TIPPING_MAILING_LIST']
      subject subject
      body    the_body
      delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
    end
    message.deliver
  end

  def all_users
    User.all
  end

  def streak(user)
    streak = {count: 0, successful: 'unknown'}
    user.tips.where(deleted: false || nil, locked: true).order(tippingweek: :desc).each do |tip|
      streak[:successful] = tip.successful if streak[:successful] == 'unknown'
      break unless streak[:successful] == tip.successful
      streak[:count] += 1
    end
    streak
  end

end

module Gambling
  def current_week
    Week.where(deleted: [false,nil]).order(tippingweek: :desc).first
  end

  def get_week_by_number(number)
    Week.where(tippingweek: number).where(deleted: [false,nil]).first
  end

  def current_tipping_week_number
    if current_week.locked
      current_week.tippingweek + 1
    else
      current_week.tippingweek
    end
  end

  def current_tipping_status
    tips = current_week.tips.reject{|x| x.deleted}
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
    # TODO: remove the tippingweek reference
    user.tips.where(deleted: false || nil, locked: true).order(tippingweek: :desc).each do |tip|
      streak[:successful] = tip.successful if streak[:successful] == 'unknown'
      break unless streak[:successful] == tip.successful
      streak[:count] += 1
    end
    streak
  end

end

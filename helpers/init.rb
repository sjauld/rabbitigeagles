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
  tips = Tip.where(tippingweek: current_week)
  if tips.count == 0
    return 'Noone has entered their tips yet. This makes Steve Menzies sad.'
  else
    return tips.map{|x| "#{x.user}: #{x.description}"}.join("\n")
  end
end

def email_the_bastards(subject,pre)
  message = Mail.new do
    from    ENV['TIPPING_FROM_ADDRESS']
    to      ENV['TIPPING_MAILING_LIST']
    subject subject
    body    "#{pre}\n\nCurrent tips:-\n#{current_tipping_status}\n\n--\nTigersearabbit Tipping System"
    delivery_method Mail::Postmark, api_token: ENV['POSTMARK_API_TOKEN']
  end
  message.deliver
end

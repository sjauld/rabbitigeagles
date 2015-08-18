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
    the_body = 'Noone has entered their tips yet. This makes Steve Menzies sad.'
  else
    the_body = tips.map{|x| "#{x.user}: #{x.description}"}.join("\n")
  end
  return the_body
end

class Week < ActiveRecord::Base
  has_many :tips

  # Calculate weekly results and store against the object
  def save_results
    self.return = calculate_payout(self.tips.reject{|t| t.deleted || !t.successful})
    self.save
    true
  end

  #######
  private
  #######

  def calculate_payout(tips)
    total = 0
    (3..6).each do |i|
      total += tips.map{|x| x.odds.to_f}.combination(i).to_a.map{|x| x.reduce(:*)}.reduce(:+).to_f
    end
    return total
  end

end

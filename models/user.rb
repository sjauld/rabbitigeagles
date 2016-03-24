class User < ActiveRecord::Base
  has_many :tips
  has_many :payments

  # Calculate the winning streak for the user
  # @return [Hash] a hash containing a count (:count) and a streak status (:successful)
  def streak
    streak = {count: 0, successful: 'unknown'}
    self.tips.where(deleted: [false,nil], locked: true).order(tippingweek: :desc).each do |tip|
      streak[:successful] = tip.successful if streak[:successful] == 'unknown'
      break unless streak[:successful] == tip.successful
      streak[:count] += 1
    end
    streak
  end

  # Calculate the total payments made by a user
  # @return [Float] the dollar value made
  def total_payments
    self.payments.map{|x| x.amount.to_f}.reduce(:+)
  end
end

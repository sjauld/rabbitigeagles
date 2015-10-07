class User < ActiveRecord::Base
  has_many :tips

  # Calculate the winning streak for the user
  # @return [Hash] a hash containing a count (:count) and a streak status (:successful)
  def streak
    streak = {count: 0, successful: 'unknown'}
    # TODO: remove the tippingweek reference, need to do something when number of tips per user gets large
    self.tips.where(deleted: false || nil, locked: true).order(tippingweek: :desc).each do |tip|
      streak[:successful] = tip.successful if streak[:successful] == 'unknown'
      break unless streak[:successful] == tip.successful
      streak[:count] += 1
    end
    streak
  end
end

class ExpandWeeksAndTips < ActiveRecord::Migration
  def change
    change_table :weeks do |t|
      t.float   :return
      t.integer :correct_tips
    end

    change_table :tips do |t|
      t.float :contribution
    end
  end
end

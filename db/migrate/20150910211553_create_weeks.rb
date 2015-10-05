class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.integer   :tippingweek
      t.float     :bettingamount
      t.float     :betreturn
      t.boolean   :locked
      t.boolean   :deleted
      t.timestamps null: false
    end

    change_table :tips do |t|
      t.belongs_to :week, index: true
    end

  end
end

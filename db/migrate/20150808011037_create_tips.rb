class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.string :user
      t.string :description
      t.timestamp :matchtime
      t.float :odds
      t.integer :tippingweek
      t.boolean :successful
      t.timestamps null: false
    end
  end
end

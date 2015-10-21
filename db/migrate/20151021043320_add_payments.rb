class AddPayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float       :amount
      t.belongs_to  :user
      t.timestamps  null: false
    end
  end
end

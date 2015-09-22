class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.string  :email
      t.string  :first_name
      t.string  :last_name
      t.string  :image
      t.timestamps null: false
    end

    change_table :tips do |t|
      t.belongs_to :user, index: true
    end

  end
end

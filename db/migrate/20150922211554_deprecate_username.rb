class DeprecateUsername < ActiveRecord::Migration
  def change
    change_table :tips do |t|
      t.rename :user, :old_username
    end
  end
end

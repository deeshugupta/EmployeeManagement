class ChangeColumn < ActiveRecord::Migration
  def up
    change_column :users, :casual, :float
    change_column :users, :sick, :float
    change_column :users, :privilege, :float
  end

  def down
  end
end

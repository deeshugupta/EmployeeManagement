class AddLeaveTypesToUser < ActiveRecord::Migration
  def change
    add_column :users, :casual, :integer
    add_column :users, :sick, :integer
    add_column :users, :privilege, :integer
    remove_column :users, :leaves_applicable
  end
end

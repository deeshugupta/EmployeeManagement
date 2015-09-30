class AddFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :employee_code, :integer
    add_column :users, :leaves_applicable, :integer
  end
end

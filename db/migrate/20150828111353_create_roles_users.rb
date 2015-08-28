class CreateRolesUsers < ActiveRecord::Migration
  def up
    create_table :roles_users do |t|
      t.integer :user_id
      t.integer :role_id
    end
  end

  def down
    drop_table :roles_users
  end
end

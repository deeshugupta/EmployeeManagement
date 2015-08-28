class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :working_days
      t.string :name
      t.integer :leaves_applicable

      t.timestamps
    end
  end
end

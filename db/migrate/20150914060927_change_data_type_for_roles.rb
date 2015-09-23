class ChangeDataTypeForRoles < ActiveRecord::Migration
  def self.up
    change_column :roles, :leaves_applicable, :float
  end

  def self.down
    change_column :roles, :leaves_applicable, :decimal, :precision => 2, :scale => 2
  end
end

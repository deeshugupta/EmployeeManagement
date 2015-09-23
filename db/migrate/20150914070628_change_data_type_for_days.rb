class ChangeDataTypeForDays < ActiveRecord::Migration
  def self.up
    change_column :attendances, :days, :float
  end

  def self.down
    change_column :attendances, :days, :integer
  end
end
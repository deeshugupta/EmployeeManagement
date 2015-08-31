class AlterAttendances < ActiveRecord::Migration
  def up
    change_column :attendances, :approval_status, :boolean
  end

  def down
  end
end

class AddLeaveTypeFieldAttendances < ActiveRecord::Migration
  def up
    add_column :attendances, :leave_type_id, :integer
  end

  def down
  end
end

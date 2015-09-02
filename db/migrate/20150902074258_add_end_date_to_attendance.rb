class AddEndDateToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances,:end_date, :date
  end
end

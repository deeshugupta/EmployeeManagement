class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.integer :user_id
      t.date :start_date
      t.integer :days
      t.boolean :is_leave_or_wfh
      t.text :reason
      t.boolean :approval_status
      t.text :comments

      t.timestamps
    end
  end
end

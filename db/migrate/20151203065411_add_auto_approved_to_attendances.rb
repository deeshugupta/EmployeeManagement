class AddAutoApprovedToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :auto_approved, :boolean, null: true

  end
end

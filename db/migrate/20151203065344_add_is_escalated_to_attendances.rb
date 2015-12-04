class AddIsEscalatedToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :is_escalated, :boolean, null: true

  end
end

class AddProcessedByToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :processed_by, :integer, null: true

  end
end

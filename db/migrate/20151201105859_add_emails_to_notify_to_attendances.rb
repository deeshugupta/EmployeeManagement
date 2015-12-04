class AddEmailsToNotifyToAttendances < ActiveRecord::Migration
  def change
    add_column :attendances, :emails_to_notify, :string
  end
end

class Attendance < ActiveRecord::Base
  include ActiveModel::Dirty
  #Associations
  belongs_to :user
  has_one :manager, :through => :user, :source => :manager
  belongs_to :leave_type

  accepts_nested_attributes_for :leave_type

  # t.date :start_date
  validates_presence_of :days
  # t.boolean :is_leave_or_wfh

  before_update do
  if self.changed?

    if self.changed_attributes.has_key?('approval_status')
      approval_status_changed =  self.changes[:approval_status]
      if !approval_status_changed.at(1).nil?
        UserMailer.changed_response(self.user, self).deliver
      else
        UserMailer.new_approval(self.manager, self).deliver
      end
    end
  end
  end

  before_create do
    UserMailer.new_approval(self.manager, self).deliver
  end


  before_destroy do
    UserMailer.delete_request(self.manager, self).deliver
  end
end

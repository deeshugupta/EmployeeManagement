class Attendance < ActiveRecord::Base
  belongs_to :user

  has_one :manager, :through => :user, :source => :manager

  def is_pending(id)
    attendance = Attendance.find(id)
    if(attendance.approval_status.nil?)
      true
    else
      false
    end
  end
end


class LeaveType < ActiveRecord::Base
  has_many :attendances
end

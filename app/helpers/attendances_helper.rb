module AttendancesHelper
def attendance_current_status(attendance)
  if(attendance.approval_status.nil?)
    :pending
  elsif(attendance.approval_status)
    :approved
  else
    :rejected

  end
end

end

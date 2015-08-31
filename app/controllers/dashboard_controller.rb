class DashboardController < ApplicationController

  respond_to :html,:js
  def index
    @attendance = Attendance.new
  end

  def approve
    @attendance = Attendance.find(params[:approval_id])
    approval_type = params[:approval_type]
    type = nil
    if(approval_type.eql?'Comment')
      type= nil
    elsif approval_type.eql?'Approve'
      type = true
    else
      type = false
    end
    @attendance.update_attributes(:comments=>params[:attendance][:comments], :approval_status=>type)
  end
end

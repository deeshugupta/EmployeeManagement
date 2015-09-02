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

  def search
   @start_date = Date.new(params[:start]['start_date(1i)'].to_i,
                          params[:start]['start_date(2i)'].to_i,
                          params[:start]['start_date(3i)'].to_i)
    @end_date = Date.new(params[:end]['end_date(1i)'].to_i,
                         params[:end]['end_date(2i)'].to_i,
                         params[:end]['end_date(3i)'].to_i)

    name =  params[:name]
    @attendances = Attendance.joins(:user).where('users.name = ?',name)
  end
end

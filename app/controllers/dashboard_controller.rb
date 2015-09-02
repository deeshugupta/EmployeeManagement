class DashboardController < ApplicationController

  respond_to :html, :js

  def index
    @attendance = Attendance.new
  end

  def approve
    @attendance = Attendance.find(params[:approval_id])
    approval_type = params[:approval_type]
    type = nil
    if (approval_type.eql? 'Comment')
      type= nil
    elsif approval_type.eql? 'Approve'
      type = true
    else
      type = false
    end
    @attendance.update_attributes(:comments => params[:attendance][:comments], :approval_status => type)
  end

  def search
    start_date = Date.new(params[:start]['start_date(1i)'].to_i,
                          params[:start]['start_date(2i)'].to_i,
                          params[:start]['start_date(3i)'].to_i)
    end_date = Date.new(params[:end]['end_date(1i)'].to_i,
                        params[:end]['end_date(2i)'].to_i,
                        params[:end]['end_date(3i)'].to_i)

    name = params[:name].split(',')
    pending = params[:pending]
    approved = params[:approved]
    rejected = params[:rejected]
    approval_status_where = ''
    leave = params[:leave]
    wfh = params[:wfh]


    if !name.nil? & !name.empty?
      @user_attendances = Attendance.joins(:user).
          where('users.name in (?) and users.manager_id = ?', name, current_user.id)
    else
      @user_attendances = Attendance.joins(:user).
          where('users.manager_id = ?', current_user.id)
    end
    if !start_date.nil?
      @user_attendances = @user_attendances.where('start_date >= ?', start_date)
    end

    if (!end_date.nil?)
      @user_attendances = @user_attendances.where('end_date <= ?', end_date)
    end
    if (!pending.nil?)
      approval_status_where = approval_status_where + 'approval_status is NULL'
    end
    if !approved.nil?
      if !approval_status_where.empty?
        approval_status_where = approval_status_where + ' OR approval_status = true'
      else
        approval_status_where = approval_status_where + 'approval_status = true'
      end
    end
    if !rejected.nil?
      if !approval_status_where.empty?
        approval_status_where = approval_status_where + ' OR approval_status = false'
      else
        approval_status_where = approval_status_where + 'approval_status = false'
      end
    end

    if !approval_status_where.empty?
      @user_attendances = @user_attendances.where(approval_status_where)

    end


    leave_type_where =''
    if (!leave.nil?)
      leave_type_where = leave_type_where+'is_leave_or_wfh = true'
    end
    if (!wfh.nil?)
      if (!leave_type_where.empty?)
        leave_type_where = leave_type_where+' OR is_leave_or_wfh = false'
      else
        leave_type_where = leave_type_where+'is_leave_or_wfh = false'
      end
    end

    if (!leave_type_where.empty?)
      @user_attendances = @user_attendances.where(leave_type_where)
    end
  end

end

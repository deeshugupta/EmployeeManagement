class DashboardController < ApplicationController

  respond_to :html, :js

  def index
    @attendance = Attendance.new
  end

  def create
    @user=User.new(params[:user])
    if params[:role].present?
      params[:role].each do |id|
        role = Role.find(id.to_i)
        @user.roles << role
      end
    else
      @user.roles << Role.find_by_name(:employee)
    end

    if @user.save!
      redirect_to root_path
    end
  end

  def new
    @managers = User.all(:include => :roles, :conditions => ["roles.name = ?", "Manager"])
    @roles_available = Role.all
    @user = User.new
  end

  def approve
    puts "params ******************"
    puts params
    @attendance = Attendance.find(params[:approval_id])
    approval_type = params[:commit]
    type = nil
    if (approval_type.eql? 'Comment')
      type= nil
    elsif approval_type.eql? 'Approve'
      type = true
    else
      type = false
    end
    @attendance.update_attributes(:comments => params[:comments], :approval_status => type)
    redirect_to pending_approvals_attendances_url
  end

  def search
    start_date = Date.new(params[:start]['start_date(1i)'].to_i,
                          params[:start]['start_date(2i)'].to_i,
                          params[:start]['start_date(3i)'].to_i)
    end_date = Date.new(params[:end]['end_date(1i)'].to_i,
                        params[:end]['end_date(2i)'].to_i,
                        params[:end]['end_date(3i)'].to_i)

    name = params[:name][0]
    pending = params[:pending]
    approved = params[:approved]
    rejected = params[:rejected]
    approval_status_where = ''
    leave = params[:leave]
    wfh = params[:wfh]

    if !name.blank?
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

    att_wfh = Attendance.where('is_leave_or_wfh = ?', false).group('user_id')
    att_leaves = Attendance.where('is_leave_or_wfh = ?', true).group('user_id')

    user_leaves_num = att_leaves.sum('days')
    user_wfh_num = att_wfh.sum('days')

    user_wfh_num.each do |att|
      uid = att.first
      uname = User.find(uid).name
      puts uname
      puts name
      if uname.to_s == name
        @work_from_home = uname + " took " + att.second.to_s + " work from home"
      end
    end

    user_leaves_num.each do |att|
      uid = att.first
      uname = User.find(uid).name
      if uname.to_s == name
        @total_leaves = uname + " took " + att.second.to_s + " leaves"
      end
    end

  end

  def search_my_requests
    start_date = Date.new(params[:start]['start_date(1i)'].to_i,
                          params[:start]['start_date(2i)'].to_i,
                          params[:start]['start_date(3i)'].to_i)
    end_date = Date.new(params[:end]['end_date(1i)'].to_i,
                        params[:end]['end_date(2i)'].to_i,
                        params[:end]['end_date(3i)'].to_i)

    pending = params[:pending]
    approved = params[:approved]
    rejected = params[:rejected]
    approval_status_where = ''
    leave = params[:leave]
    wfh = params[:wfh]

    @user_attendances = Attendance.joins(:user).
        where('users.id = ?', current_user.id)

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

    respond_to do |format|
      format.js { render :template => "dashboard/search_my_requests" }
    end

  end

  def my_team

  end

end
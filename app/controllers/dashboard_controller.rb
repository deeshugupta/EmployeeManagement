class DashboardController < ApplicationController

  respond_to :html, :js
  before_filter :check_manager_or_admin, only: :entire_team

  def index
    @attendance = Attendance.new
  end

  def approve
    @attendance = Attendance.find(params[:approval_id])
    approval_type = params[:commit_action]
    comments = params[:comments]
    if params[:emails_to_notify]
      @attendance.emails_to_notify = params[:emails_to_notify]
      @attendance.save()
    end
    @attendance.process(current_user, approval_type, comments)
    redirect_to pending_approvals_attendances_url
  end

  def search
    start_date = nil
    end_date   = nil
    if !params[:start]['start_date(1i)'].blank?
      start_date = Date.new(params[:start]['start_date(1i)'].to_i, params[:start]['start_date(2i)'].to_i, params[:start]['start_date(3i)'].to_i)
    end
    if !params[:end]['end_date(1i)'].blank?
      end_date = Date.new(params[:end]['end_date(1i)'].to_i, params[:end]['end_date(2i)'].to_i, params[:end]['end_date(3i)'].to_i)
    end

    name = params[:name][0]
    user_id = params[:user_id]
    manager_user_id = params[:manager_user_id]
    pending = params[:pending]
    approved = params[:approved]
    rejected = params[:rejected]
    approval_status_where = ''
    leave = params[:leave]
    wfh = params[:wfh]
    casual = params[:casual]
    sick = params[:sick]
    privilege = params[:privilege]

    if !user_id.blank?
      @user_attendances = Attendance.joins(:user, :leave_type).
          where('users.id=? and users.manager_id = ?', user_id, current_user.id)
    elsif !manager_user_id.blank?
      @user_attendances = Attendance.joins(:user, :leave_type).
          where('users.manager_id = ?', manager_user_id)
    else
      if current_user.is_manager? || current_user.is_admin?
        @user_attendances = Attendance.joins(:user, :leave_type).where("user_id IN (?)", current_user.entire_team.collect(&:id))
      else
        @user_attendances = Attendance.joins(:user, :leave_type).joins(:user, :leave_type).
          where('users.manager_id = ?', current_user.id)
      end
    end
    if !start_date.nil?
      @user_attendances = @user_attendances.where('start_date >= ?', start_date)
    end

    if (!end_date.nil?)
      @user_attendances = @user_attendances.where('end_date <= ?', end_date)
    end
    if !pending.nil?
      approval_status_where = approval_status_where + 'approval_status is NULL'
    end
    if !approved.nil?
      if !approval_status_where.empty?
        approval_status_where = approval_status_where + ' OR approval_status = true'
      else
        approval_status_where = 'approval_status = true'
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

    leave_category_where =''
    if (!leave.nil?)
      leave_category_where = leave_category_where+'is_leave_or_wfh = true'
    end
    if (!wfh.nil?)
      if (!leave_category_where.empty?)
        leave_category_where = leave_category_where+' OR is_leave_or_wfh = false'
      else
        leave_category_where = leave_category_where+'is_leave_or_wfh = false'
      end
    end




    if (!leave_category_where.empty?)
      @user_attendances = @user_attendances.where(leave_category_where)
    end

    leave_type_where=""
    if(!casual.nil?)
      leave_type_where = leave_type_where + " leave_types.name like 'casual' "
    end

    if !sick.nil?
      if !leave_type_where.empty?
        leave_type_where = leave_type_where + " OR leave_types.name like 'sick' "
      else
        leave_type_where = leave_type_where + " leave_types.name like 'sick' "
      end
    end

    if !privilege.nil?
      if !leave_type_where.empty?
        leave_type_where = leave_type_where + " OR leave_types.name like 'privilege' "
      else
        leave_type_where = leave_type_where + " leave_types.name like 'privilege' "
      end
    end

    if (!leave_type_where.empty?)
      @user_attendances = @user_attendances.where(leave_type_where)
    end

    @user_attendances = @user_attendances.paginate(per_page: 10, page: params[:page])

    @sick = Attendance.joins(:user,:leave_type)
                      .where("users.name like ?
                              and leave_types.name like ?
                              and start_date >= ?
                              and end_date <= ?
                              and is_leave_or_wfh = true
                              and approval_status = true",
                              name,'sick',start_date, end_date).sum('attendances.days')

    @casual = Attendance.joins(:user,:leave_type)
                .where("users.name like ?
                              and leave_types.name like ?
                              and start_date >= ?
                              and end_date <= ?
                              and is_leave_or_wfh = true
                              and approval_status = true",
                       name,'casual',start_date, end_date).sum('attendances.days')

    @privilege = Attendance.joins(:user,:leave_type)
                .where("users.name like ?
                              and leave_types.name like ?
                              and start_date >= ?
                              and end_date <= ?
                              and is_leave_or_wfh = true
                              and approval_status = true",
                       name,'privilege',start_date, end_date).sum('attendances.days')
    @name = name

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
    @my_team = current_user.team_members.paginate(page: params[:page], per_page: 20).order(:name)
  end

  def entire_team
    @entire_team = current_user.entire_team.paginate(:page => params[:page], :per_page => 20)
  end

  private

  def check_manager_or_admin
    redirect_to root_path if (!current_user.is_manager? && !current_user.is_admin?)
  end

end

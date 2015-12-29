class UserMailer < ActionMailer::Base
  add_template_helper(AttendancesHelper)
  add_template_helper(ApplicationHelper)
  default from: "notifications@admin.tt.com"

  def changed_response(user, attendance)
    @user = user
    @attendance = attendance
    mail(:to => @user.email, :subject => "Leave status changed")
  end

  def new_approval(user, attendance)
    @user = user
    @attendance = attendance
    mail(:to => @user.email, :subject => "New Leave Request Submitted")
  end

  def notify_approval_to_email_getters(user, attendance)
    @user = user
    @attendance = attendance
    @receivers = @attendance.email_notification_getters
    if !@receivers.blank?
      mail(:to => @receivers, :subject => "#{@user.name}'s Leave Notification")
    end
  end

  def delete_request(user, attendance)
    @user = user
    @attendance = attendance
    mail(:to => @user.email, :subject => "Leave Request Deleted")
  end

  def team_monthly_leaves_email(manager, month, year)
    @manager = manager
    @month = month
    @year = year
    @month_start = "#{year}-#{month-1}-25"
    @month_end = "#{year}-#{month}-25"
    mail(:to => manager.email, :cc => Role.admin.users.collect(&:email).to_a, :subject => "Team Monthly Leave Information")
  end

  def escalate_approval_email(attendance)
    @attendance = attendance
    @manager = attendance.user.manager
    @m_manager = @manager.manager
    @leave_or_wfh = attendance.is_leave_or_wfh ? 'Leave' : 'WFH'
    mail(:to => @m_manager.email, :cc => @manager.email, :subject => "#{@leave_or_wfh} Approval Request Escalated")
  end

  def auto_approved_email(attendance)
    @attendance = attendance
    @manager = attendance.user.manager
    @m_manager = @manager.manager
    @leave_or_wfh = attendance.is_leave_or_wfh ? 'Leave' : 'WFH'
    if !@m_manager.nil?
      mail(:to => @m_manager.email, :cc => @manager.email, :subject => "#{@leave_or_wfh} Approval Request Auto Approved")
    else
      mail(:to => @manager.email, :subject => "#{@leave_or_wfh} Approval Request Auto Approved")
    end
  end

  def user_registered_email(user)
    @user = user
    mail(:to => @user.email, :subject => "#{@leave_or_wfh} Approval Request Auto Approved")
  end

end

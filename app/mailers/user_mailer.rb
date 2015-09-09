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

  def delete_request(user, attendance)
    @user = user
    @attendance = attendance
    mail(:to => @user.email, :subject => "Leave Request Deleted")
  end

end

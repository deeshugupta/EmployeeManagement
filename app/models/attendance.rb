class Attendance < ActiveRecord::Base
  include ActiveModel::Dirty
  #Associations
  belongs_to :user
  has_one :manager, :through => :user, :source => :manager
  belongs_to :leave_type

  accepts_nested_attributes_for :leave_type

  # t.date :start_date
  validates_presence_of :days
  # t.boolean :is_leave_or_wfh

  before_update do
  if self.changed?

    if self.changed_attributes.has_key?('approval_status')
      approval_status_changed =  self.changes[:approval_status]
      if !approval_status_changed.at(1).nil?
        UserMailer.changed_response(self.user, self).deliver
        if approval_status_changed.at(1) == true
          UserMailer.notify_approval_to_email_getters(self.user, self).deliver
        end
      else
        UserMailer.new_approval(self.manager, self).deliver
      end
    end
  end
  end

  before_create do
    UserMailer.new_approval(self.manager, self).deliver
  end


  before_destroy do
    UserMailer.delete_request(self.manager, self).deliver
  end

  def email_notification_getters
    email_getters = []
    if !emails_to_notify.blank?
      emails = emails_to_notify.split(',')
      if !emails.blank?
        emails.each do |email|
          email_getters << email
        end
      end
    end
    return email_getters
  end

  def approval_escalation_needed
    if self.is_leave_or_wfh && !self.is_escalated
      return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['leave_escalation_days'] * 24
    elsif !self.is_leave_or_wfh && !self.is_escalated
      return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['wfh_escalation_days'] * 24
    end
  end

  # call this method only if approval_escalation_needed returns true
  def escalate_approval
    if !self.user.manager_id.nil?
      if self.manager.manager_id.nil?
        self.auto_approve()
      else
        UserMailer.escalate_approval_email(self).deliver
        self.is_escalated = true
        self.save
      end
    end
  end

  def auto_approval_needed
    if !self.user.manager_id.nil?
      if self.user.manager.manager_id.nil?
        if self.approval_escalation_needed
          return true
        end
      else
        if self.is_leave_or_wfh && self.is_escalated
          return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['leave_escalation_days'] * 24 * 2
        elsif !self.is_leave_or_wfh && self.is_escalated
          return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['wfh_escalation_days'] * 24 * 2
        end
      end
    end
  end

  # call this method only if auto_approval_needed returns true
  def auto_approve
    if !self.auto_approved
      UserMailer.auto_approved_email(self).deliver
      self.auto_approved = true
      self.save
    end
  end
end

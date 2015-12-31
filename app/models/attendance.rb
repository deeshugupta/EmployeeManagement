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
            if !self.email_notification_getters.blank?
              UserMailer.notify_approval_to_email_getters(self.user, self).deliver
            end
          end
        else
          UserMailer.new_approval(self.manager, self).deliver
        end
      end
    end
  end

  before_save do
    if self.emails_to_notify.is_a?(Array)
      self.emails_to_notify.delete("---\n- ''\n")
      self.emails_to_notify.delete("")
      self.emails_to_notify.delete(nil)
      self.emails_to_notify = self.emails_to_notify.select{|email| !email.blank?}.join(",")
    end
  end

  before_create do
    UserMailer.new_approval(self.manager, self).deliver
  end


  before_destroy do
    UserMailer.delete_request(self.manager, self).deliver
  end

  def processed_by_user
    if !self.processed_by.nil?
      return User.find(processed_by).email
    elsif self.approval_status == true
      return "Auto approved"
    else
      return "Approval awaiting"
    end
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
      self.approval_status = true
      self.save
    end
  end


  def process(manager, approval_type, new_comments)
    if (self.user.manager_id == manager.id) || (!self.user.manager.manager.nil? and self.user.manager.manager.id == manager.id) || manager.is_admin?
      a_type = nil
      if (approval_type.eql? 'comment')
        a_type= nil
      elsif approval_type.eql? 'approve'
        a_type = true
        if self.leave_type.name == 'Casual'
          self.user.decrement_casual_leave(self.days)
        elsif self.leave_type.name == 'Sick'
          self.user.decrement_sick_leave(self.days)
        elsif self.leave_type.name == 'Privilege'
          self.user.decrement_privilege_leave(self.days)
        end
      else
        a_type = false
      end
      self.update_attributes(:comments => self.comments.to_s+":##:"+new_comments.to_s, :approval_status => a_type, :processed_by => manager.id)
    end
  end

  # this method is called by cron job to escalate or auto approve the pending approvals if approval escalation is needed or auto approval is needed
  def self.auto_process()
    self.where("approval_status IS NULL").each do |leave|
      if leave.approval_escalation_needed
        leave.escalate_approval
      elsif leave.auto_approval_needed
        leave.auto_approve
      end
    end
  end

  def remaining_type_leaves
    if self.leave_type.name == 'Sick'
      self.user.sick
    elsif self.leave_type.name == 'Casual'
      self.user.casual
    elsif self.leave_type.name == 'Privilege'
      self.user.privilege
    end
  end

  # day here must be of a date class instance
  def self.is_uncountable_day?(user, day)
    return true if (day.sunday? || (user.is_dev? && day.saturday?) || Holiday.is_in_between_holiday?(day))
    return false
  end
end

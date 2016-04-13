class Attendance < ActiveRecord::Base
  include ActiveModel::Dirty
  #Associations
  belongs_to :user
  has_one :manager, :through => :user, :source => :manager
  belongs_to :leave_type

  accepts_nested_attributes_for :leave_type

  # t.date :start_date
  validates_presence_of :days
  validates_presence_of :start_date
  validates_presence_of :leave_type_id
  validates_inclusion_of :is_leave_or_wfh, :in => [true, false]
  # t.boolean :is_leave_or_wfh

  before_update do
    if self.changed?
      self.fix_emails_to_notify
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
    self.set_end_date
    self.fix_emails_to_notify
  end

  before_create do
    UserMailer.new_approval(self.manager, self).deliver
  end


  before_destroy do
    UserMailer.delete_request(self.manager, self).deliver
  end

  def set_end_date
    self.days = self.days.abs
    if self.days != 0.5
      self.end_date= self.start_date + self.days.days - 1.days
    else
      self.end_date= self.start_date + self.days.days - self.days.days
    end
  end


  def fix_emails_to_notify
    if self.emails_to_notify.is_a?(Array)
      e_to_notify = self.emails_to_notify
      e_to_notify.map{|email| email.scan(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).map{|e| e[0..-1]}}.flatten
      self.emails_to_notify = e_to_notify.join(",")
    elsif !self.emails_to_notify.blank?
      e_to_notify = self.emails_to_notify.scan(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).map{|e| e[0..-1]}
      self.emails_to_notify = e_to_notify.join(",")
    end
    
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
    if self.emails_to_notify.is_a?(Array)
      self.emails_to_notify = self.emails_to_notify.select{|email| !email.blank? }.join(",")
    end
    if !self.emails_to_notify.blank?
      email_getters = self.emails_to_notify.scan(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i).map{|e| e[0..-1]}
    end
    return email_getters
  end

  def approval_escalation_needed?
    return false if !self.approval_status.nil?
    if self.is_leave_or_wfh && !self.is_escalated
      return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['leave_escalation_days'] * 24
    elsif !self.is_leave_or_wfh && !self.is_escalated
      return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['wfh_escalation_days'] * 24
    else
      return false
    end
  end

  # call this method only if approval_escalation_needed? returns true
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

  def auto_approval_needed?
    return false if !self.approval_status.nil?
    if !self.user.manager_id.nil?
      if self.user.manager.manager_id.nil?
        return self.approval_escalation_needed?
      else
        if self.is_leave_or_wfh && self.is_escalated
          return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['leave_escalation_days'] * 24 * 2
        elsif !self.is_leave_or_wfh && self.is_escalated
          return (Date.today.beginning_of_day - self.created_at)/(60*60) > APP_CONFIG['wfh_escalation_days'] * 24 * 2
        else
          return false
        end
      end
    end
  end

  # call this method only if auto_approval_needed? returns true
  def auto_approve
    if !self.auto_approved && self.approval_status.nil?
      UserMailer.auto_approved_email(self).deliver
      self.process(nil, 'approve', 'auto_approved')
    end
  end


  def process(manager, approval_type, new_comments)
    if manager.blank?
      a_type = true
      manager_id = nil
    elsif (self.user.manager_id == manager.id) || (!self.user.manager.manager.nil? and self.user.manager.manager.id == manager.id) || manager.is_admin?
      a_type = nil
      if approval_type.eql? 'approve'
        a_type = true
      else
        a_type = false
      end
      manager_id = manager.id
    end
    self.update_attributes(:comments => self.comments.to_s+":##:"+new_comments.to_s, :approval_status => a_type, :processed_by => manager_id)
    if a_type == true
      if self.leave_type.name == 'Casual'
        self.user.decrement_casual_leave(self.actual_days)
      elsif self.leave_type.name == 'Sick'
        self.user.decrement_sick_leave(self.actual_days)
      elsif self.leave_type.name == 'Privilege'
        self.user.decrement_privilege_leave(self.actual_days)
      end
    end
  end

  # this method is called by cron job to escalate or auto approve the pending approvals if approval escalation is needed or auto approval is needed
  def self.auto_process()
    self.where("approval_status IS NULL").each do |leave|
      if leave.approval_escalation_needed?
        leave.escalate_approval
      elsif leave.auto_approval_needed?
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

  def actual_days
    (self.start_date..self.end_date).select{|leave_date| !Attendance.is_uncountable_day?(self.user, leave_date) }.count
  end
end

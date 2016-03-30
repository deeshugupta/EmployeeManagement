class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :manager_id, :join_date, :sick, :casual, :privilege, :roles, :employee_code

  validates_presence_of :email
  validates_presence_of :sick, if: :joined_before_current_year?
  validates_presence_of :casual, if: :joined_before_current_year?
  validates_presence_of :privilege, if: :joined_before_current_year?
  validates_presence_of :manager_id, if: :is_dev?
  validates_confirmation_of :password

  #Associations
  has_many :attendances
  has_many :team_members, :class_name => "User", :foreign_key => :manager_id
  belongs_to :manager, :class_name => "User"

  # has_many :approvals, :through => :team_members, :source => :attendances

  has_and_belongs_to_many :roles

  accepts_nested_attributes_for :roles

  after_save :leaves_setup

  def joined_before_current_year?
    return self.join_date.present? && (self.join_date.year < DateTime.now.year)
  end

  def approvals
    if self.is_admin?
      Attendance.where("user_id IN (?)",self.entire_team.collect(&:id))
    else self.is_manager?
      Attendance.where("user_id IN (?)",self.team_members.collect(&:id))
    end
  end

  def self.managers
    Role.where(name: "Manager").first.users
  end

  def self.developers
    Role.where(name: "Developer").first.users
  end

  def self.admins
    Role.where(name: "admin").first.users
  end

  def is_admin?
    roles.collect(&:name).include?(Role.admin.name)
  end

  def is_manager?
    roles.collect(&:name).include?(Role.manager.name)
  end

  def is_dev?
    roles.collect(&:name).include?(Role.developer.name)
    # roles.where(name: 'Developer').count != 0
  end

  def entire_team
    all_team_members = []
    if self.is_admin?
      all_team_members = User.where("id!=#{self.id}")
    elsif self.is_manager?
      self.team_members.each do |t_member|
        all_team_members << t_member
        all_team_members << t_member.entire_team
      end
    end
    all_team_members.flatten.uniq
  end

  def approved_leaves
    self.attendances.where(:approval_status => true, :is_leave_or_wfh => true)
  end

  def rejected_leaves
    self.attendances.where(:approval_status => false, :is_leave_or_wfh => true)
  end

  def approved_wfhs
    self.attendances.where(:approval_status => true, :is_leave_or_wfh => false)
  end

  # from_date and to_date here will be just strings
  def leaves_for_time_period(from_date, to_date)
    leaves = self.approved_leaves.where("start_date > ? AND start_date <= ? AND end_date <= ?", from_date, to_date, to_date)
    leave_dates = []
    leaves.each do |leave|
      leave_dates << leave.start_date.upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end
    leave_dates.flatten
  end

  def leaves_for_month(month, year)
    month_start_day = APP_CONFIG['month_start_day']
    month_end_day = APP_CONFIG['month_end_day']
    if month == 1
      start_date = "#{year-1}-12-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-01-#{month_end_day.to_s.rjust(2,'0')}"
    else
      start_date = "#{year}-#{(month-1).to_s.rjust(2,'0')}-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-#{month.to_s.rjust(2,'0')}-#{month_end_day.to_s.rjust(2,'0')}"
    end
    month_leaves= self.leaves_for_time_period(start_date, end_date)

    # leaves that are started before starting of month and end after starting of month
    e_leaves_1 = self.approved_leaves.where("start_date < ? AND end_date > ?", start_date, start_date)
    e_leaves_2 = self.approved_leaves.where("start_date <= ? AND end_date > ?", end_date, end_date)
    leaves_1 = []
    e_leaves_1.each do |leave|
      leaves_1 << Date.parse(start_date).upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end

    leaves_2 = []
    e_leaves_2.each do |leave|
      leaves_2 << leave.start_date.upto(Date.parse(end_date)).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end
    total_leaves = month_leaves + leaves_1 + leaves_2
    total_leaves.flatten
  end


  def breakdown_of_leaves_for_month(month, year)
    month_start_day = APP_CONFIG['month_start_day']
    month_end_day = APP_CONFIG['month_end_day']
    if month == 1
      start_date = "#{year-1}-12-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-01-#{month_end_day.to_s.rjust(2,'0')}"
    else
      start_date = "#{year}-#{(month-1).to_s.rjust(2,'0')}-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-#{month.to_s.rjust(2,'0')}-#{month_end_day.to_s.rjust(2,'0')}"
    end

    leaves = self.approved_leaves.where("start_date > ? AND start_date <= ? AND end_date <= ?", start_date, end_date, end_date)

    # leaves that are started before starting of month and end after starting of month
    e_leaves_1 = self.approved_leaves.where("start_date < ? AND end_date > ?", start_date, start_date)
    e_leaves_2 = self.approved_leaves.where("start_date <= ? AND end_date > ?", end_date, end_date)

    leave_type_sick = LeaveType.find_by_name('Sick')
    sick_leaves = leaves.where(leave_type_id: leave_type_sick.id)
    sick_e_leaves_1 = self.approved_leaves.where("start_date < ? AND end_date > ?", start_date, start_date).where(leave_type_id: leave_type_sick.id)
    sick_e_leaves_2 = self.approved_leaves.where("start_date <= ? AND end_date > ?", end_date, end_date).where(leave_type_id: leave_type_sick.id)
    total_sick_leaves = (sick_leaves + sick_e_leaves_1 + sick_e_leaves_2).flatten
    sick_leave_dates = []
    total_sick_leaves.each do |leave|
      sick_leave_dates << leave.start_date.upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end

    leave_type_casual = LeaveType.find_by_name('Casual')
    casual_leaves = leaves.where(leave_type_id: leave_type_casual.id)
    casual_e_leaves_1 = self.approved_leaves.where("start_date < ? AND end_date > ?", start_date, start_date).where(leave_type_id: leave_type_casual.id)
    casual_e_leaves_2 = self.approved_leaves.where("start_date <= ? AND end_date > ?", end_date, end_date).where(leave_type_id: leave_type_casual.id)
    total_casual_leaves = (casual_leaves + casual_e_leaves_1 + casual_e_leaves_2).flatten
    casual_leave_dates = []
    total_casual_leaves.each do |leave|
      casual_leave_dates << leave.start_date.upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end

    leave_type_privilege = LeaveType.find_by_name('Privilege')
    privilege_leaves = leaves.where(leave_type_id: leave_type_privilege.id)
    privilege_e_leaves_1 = self.approved_leaves.where("start_date < ? AND end_date > ?", start_date, start_date).where(leave_type_id: leave_type_privilege.id)
    privilege_e_leaves_2 = self.approved_leaves.where("start_date <= ? AND end_date > ?", end_date, end_date).where(leave_type_id: leave_type_privilege.id)
    total_privilege_leaves = (privilege_leaves + privilege_e_leaves_1 + privilege_e_leaves_2).flatten
    privilege_leave_dates = []
    total_privilege_leaves.each do |leave|
      privilege_leave_dates << leave.start_date.upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end
    return {"sick" => sick_leave_dates.flatten, "casual" => casual_leave_dates.flatten, "privilege" => privilege_leave_dates.flatten}
  end

  def wfh_for_time_period(from_date, to_date)
    leaves = self.approved_wfhs.where("start_date > ? AND start_date <= ? AND end_date <= ?", from_date, to_date, to_date)
    leave_dates = []
    leaves.each do |leave|
      leave_dates << leave.start_date.upto(leave.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end
    leave_dates.flatten
  end

  def wfh_for_month(month, year)
    month_start_day = APP_CONFIG['month_start_day']
    month_end_day = APP_CONFIG['month_end_day']
    if month == 1
      start_date = "#{year-1}-12-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-01-#{month_end_day.to_s.rjust(2,'0')}"
    else
      start_date = "#{year}-#{(month-1).to_s.rjust(2,'0')}-#{month_start_day.to_s.rjust(2,'0')}"
      end_date = "#{year}-#{month.to_s.rjust(2,'0')}-#{month_end_day.to_s.rjust(2,'0')}"
    end
    print start_date
    print end_date
    month_wfhs= self.wfh_for_time_period(start_date, end_date)

    # wfhs that are started before starting of month and end after starting of month
    e_wfhs_1 = self.approved_wfhs.where("start_date <= ? AND end_date > ?", start_date, start_date)
    e_wfhs_2 = self.approved_wfhs.where("start_date <= ? AND end_date > ?", end_date, end_date)
    wfhs_1 = []
    e_wfhs_1.each do |wfh|
      wfhs_1 << Date.parse(start_date).upto(wfh.end_date).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end

    wfhs_2 = []
    e_wfhs_2.each do |wfh|
      wfhs_2 << wfh.start_date.upto(Date.parse(end_date)).select {|dt| !Attendance.is_uncountable_day?(self, dt)}
    end
    total_wfhs = month_wfhs + wfhs_1 + wfhs_2
    total_wfhs.flatten
  end

  def self.send_monthly_team_leaves
    Role.where(:name=>'Manager').first.users.each do |manager|
      UserMailer.team_monthly_leaves_email(manager, Date.today.month, Date.today.year).deliver
    end
  end

  def self.increment_leaves_count_for_all_employees
    self.all.each do |user|
      user.privilege += 1.5
      user.save
    end
  end

  def decrement_sick_leave(count)
    self.sick -= count
    self.save
  end

  def decrement_casual_leave(count)
    self.casual -= count
    self.save
  end

  def decrement_privilege_leave(count)
    self.privilege -= count
    self.save
  end

  def increment_sick_leave(count)
    self.sick += count
    self.save
  end

  def increment_casual_leave(count)
    self.casual += count
    self.save
  end

  def increment_privilege_leave(count)
    self.privilege += count
    self.save
  end

  def leaves_setup
    if self.is_dev? && self.sick.blank? && (DateTime.now.year == self.join_date.year)
      self.sick = ((13 - self.join_date.month) * APP_CONFIG['sick_per_month'])
      self.casual = ((13 - self.join_date.month) * APP_CONFIG['casual_per_month'])
      self.privilege = ((DateTime.now.month - self.join_date.month)) * 1.5
      self.save
    end
  end
end

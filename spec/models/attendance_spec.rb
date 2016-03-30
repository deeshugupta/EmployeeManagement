require 'rails_helper'
require 'pry'
RSpec.describe Attendance, :type => :model do
  before(:all) do
    @sick_leave_type = FactoryGirl.create(:sick)
    @casual_leave_type = FactoryGirl.create(:casual)
    @privilege_leave_type = FactoryGirl.create(:privilege)
    FactoryGirl.create(:admin_role)
    FactoryGirl.create(:manager_role)
    FactoryGirl.create(:developer_role)
  end
  after(:all) do
    LeaveType.delete_all
    Role.delete_all
    User.delete_all
    Attendance.delete_all
    Holiday.delete_all
  end
  describe "on application of leave" do
    context "validations" do
      it "should validate start_date not to be nil" do
        attendance = FactoryGirl.build(:attendance, start_date: nil, days: 4)
        attendance.valid?
        expect(attendance.errors.messages[:start_date]).to eq(["can't be blank"])
      end
      it "should validate days not to be nil" do
        attendance = FactoryGirl.build(:attendance, start_date: DateTime.now + 1.day, days: nil)
        attendance.valid?
        expect(attendance.errors.messages[:days]).to eq(["can't be blank"])
      end

      it "should validate leave_type not to be nil" do
        attendance = FactoryGirl.build(:attendance, start_date: DateTime.now + 1.day, days: 4)
        attendance.valid?
        expect(attendance.errors.messages[:leave_type_id]).to eq(["can't be blank"])
      end
    end
    it "should properly calculate end_date" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      start_date = DateTime.now + 1.day
      attendance = FactoryGirl.create(:attendance, start_date: start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: dev.id, is_leave_or_wfh: true)
      expect(attendance.end_date).to eq(start_date + 6.days - 1.day)
    end

    it "should treat saturday as uncountable day from leave dates for dev user" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      saturday = (Date.today.monday - 2.days)
      expect(Attendance.is_uncountable_day?(dev, saturday)).to eq(true)
    end

    it "should treat sunday as uncountable day from leave dates for dev user" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      sunday = (Date.today.monday - 1.days)
      expect(Attendance.is_uncountable_day?(dev, sunday)).to eq(true)
    end

    it "should not treat monday to friday as uncountable date" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      monday = (Date.today.monday)
      expect(Attendance.is_uncountable_day?(dev, monday)).to eq(false)
      tuesday = (Date.today.monday + 1.days)
      expect(Attendance.is_uncountable_day?(dev, tuesday)).to eq(false)
      wednesday = (Date.today.monday + 2.days)
      expect(Attendance.is_uncountable_day?(dev, wednesday)).to eq(false)
      thrusday = (Date.today.monday + 3.days)
      expect(Attendance.is_uncountable_day?(dev, thrusday)).to eq(false)
      friday = (Date.today.monday + 4.days)
      expect(Attendance.is_uncountable_day?(dev, friday)).to eq(false)
    end

    it "should treat any holiday as uncountable day" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      holiday = FactoryGirl.create(:holiday, name: 'Diwali', on_date: '2016-03-15', days: 2)
      expect(Attendance.is_uncountable_day?(dev, holiday.on_date)).to eq(true)
      expect(Attendance.is_uncountable_day?(dev, holiday.on_date + 1.day)).to eq(true)
    end

    it "should properly count the leave dates by excluding any saturdays/sundays/holidays in between the applied leaves days" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      start_date = DateTime.now + 1.day
      attendance = FactoryGirl.create(:attendance, start_date: start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: dev.id, is_leave_or_wfh: true)
      end_date = attendance.end_date
      leave_dates = []
      (start_date..end_date).each do |dt|
        if !Attendance.is_uncountable_day?(dev, dt)
          leave_dates << dt
        end
      end
      expect(attendance.actual_days).to eq(leave_dates.count)
    end

    it "should deduct actual days count from applied leave type on approval" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      start_date = DateTime.now + 1.day
      attendance = FactoryGirl.create(:attendance, start_date: start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: dev.id, is_leave_or_wfh: true)
      attendance.process(manager, 'approve', "Approving the leaves")
      dev.reload
      expect(dev.casual).to eq(6 - attendance.actual_days)
    end

    it "should deduct actual days count from applied leave type on auto approval" do
      manager = FactoryGirl.create(:manager_user)
      dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: manager.id)
      start_date = DateTime.now + 1.day
      attendance = FactoryGirl.create(:attendance, start_date: start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: dev.id, is_leave_or_wfh: true)
      attendance.auto_approve
      dev.reload
      expect(dev.casual).to eq(6 - attendance.actual_days)
    end

    context "approval_escalation_needed?" do
      before(:each) do
        @manager = FactoryGirl.create(:manager_user)
        @dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: @manager.id)
        @start_date = DateTime.now + 1.day
        @attendance = FactoryGirl.create(:attendance, start_date: @start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: @dev.id, is_leave_or_wfh: true, is_escalated: false)
      end
      it "should return true if leave is a leave and added before #{APP_CONFIG['leave_escalation_days']} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 2.days - 1.minute
        @attendance.save
        expect(@attendance.approval_escalation_needed?).to eq(true)
      end
      it "should return false if leave is a leave and added after #{APP_CONFIG['leave_escalation_days']} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 1.day
        @attendance.save
        expect(@attendance.approval_escalation_needed?).to eq(false)
      end
      it "should return true if leave is a wfh and added before #{APP_CONFIG['wfh_escalation_days']} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 1.day
        @attendance.is_leave_or_wfh = false
        @attendance.save
        expect(@attendance.approval_escalation_needed?).to eq(true)
      end

      it "should return false if leave is a wfh and added before #{APP_CONFIG['wfh_escalation_days']} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day
        @attendance.is_leave_or_wfh = false
        @attendance.save
        expect(@attendance.approval_escalation_needed?).to eq(false)
      end
    end



    context "auto_approval_needed?" do
      before(:each) do
        @manager = FactoryGirl.create(:manager_user)
        @dev = FactoryGirl.create(:dev_user, join_date: DateTime.now.beginning_of_year, manager_id: @manager.id)
        @start_date = DateTime.now + 1.day
        @attendance = FactoryGirl.create(:attendance, start_date: @start_date, days: 6, leave_type_id: @casual_leave_type.id, user_id: @dev.id, is_leave_or_wfh: true, is_escalated: false)
      end
      it "should return true if leave is a leave and added before #{APP_CONFIG['leave_escalation_days'] * 2} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 4.days - 1.minute
        @attendance.save
        expect(@attendance.auto_approval_needed?).to eq(true)
      end
      it "should return false if leave is a leave and added after #{APP_CONFIG['leave_escalation_days'] * 2} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 2.day
        @attendance.save
        expect(@attendance.auto_approval_needed?).to eq(false)
      end
      it "should return false if wfh is a wfh and added before #{APP_CONFIG['wfh_escalation_days'] * 2} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day - 2.day
        @attendance.is_leave_or_wfh = false
        @attendance.save
        expect(@attendance.auto_approval_needed?).to eq(true)
      end

      it "should return false if wfh is a wfh and added before #{APP_CONFIG['wfh_escalation_days'] * 2} days from now" do
        @attendance.created_at = DateTime.now.beginning_of_day + 1.day
        @attendance.is_leave_or_wfh = false
        @attendance.save
        expect(@attendance.auto_approval_needed?).to eq(false)
      end
    end
  end
end

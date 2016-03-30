require 'rails_helper'

RSpec.describe User, :type => :model do
  before(:all) do
    FactoryGirl.create(:admin_role)
    FactoryGirl.create(:manager_role)
    FactoryGirl.create(:developer_role)
  end
  after(:all) do
    Role.delete_all
  end
  describe "after creating a new user" do
    context "Settings of available leaves" do
      before(:each) do
        join_date = DateTime.now.beginning_of_year
        manager_user = FactoryGirl.create(:manager_user, join_date: join_date)
        @dev_user = FactoryGirl.create(:dev_user, manager_id: manager_user.id, join_date: join_date)
      end
      it "should properly set sick leaves when joining date is current year" do
        expect(@dev_user.sick).to eq((13 - @dev_user.join_date.month) * APP_CONFIG['sick_per_month'])
        
      end
      it "should properly set casual leaves when joining date is current year" do
        expect(@dev_user.casual).to eq((13 - @dev_user.join_date.month) * APP_CONFIG['casual_per_month'])
      end
      it "should properly set privilege leaves when joining date is current year" do
        expect(@dev_user.privilege).to eq(APP_CONFIG['privilege_per_month'] * (DateTime.now.month - @dev_user.join_date.month))
      end
    end
  end

  describe "while creating a new user" do
    context "the validations" do
      before(:each) do
        join_date = (DateTime.now - 1.year).beginning_of_year 
        manager_user = FactoryGirl.create(:manager_user, join_date: join_date, sick: 6, casual: 6, privilege: 18)
        @dev_user = FactoryGirl.build(:dev_user, manager_id: manager_user.id, join_date: join_date)
      end
      it "should validate sick leaves not to be nil" do
        @dev_user.valid?
        expect(@dev_user.errors.messages[:sick]).to eq(["can't be blank"])
      end

      it "should validate casual leaves not to be nil" do
        @dev_user.valid?
        expect(@dev_user.errors.messages[:sick]).to eq(["can't be blank"])
      end

      it "should validate privilege leaves not to be nil" do
        @dev_user.valid?
        expect(@dev_user.errors.messages[:sick]).to eq(["can't be blank"])
      end

      it "should validate for presence of manager_id for dev user" do
        @dev_user.email = "testing@gmail.com"
        @dev_user.roles << Role.developer
        @dev_user.manager_id = nil
        @dev_user.valid?
        expect(@dev_user.errors.messages[:manager_id]).to eq(["can't be blank"])
      end
    end
  end
end

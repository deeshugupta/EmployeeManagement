FactoryGirl.define do


  factory :admin_user, class: User do
    sequence(:email) { |n| "admin+#{n}@gmail.com" }
    password "password"
    sequence(:name) {|n| "Admin #{n}"}
    before :create do |user|
      if Role.admin.blank?
        FactoryGirl.create(:admin_role)
      end
      user.roles << Role.admin
    end
  end

  factory :manager_user, class: User do
    sequence(:email) { |n| "manager+#{n}@gmail.com" }
    password "password"
    sequence(:name) {|n| "Manager #{n}"}
    before :create do |user|
      if Role.manager.blank?
        FactoryGirl.create(:manager_role)
      end
      user.roles << Role.manager
    end
  end

  factory :dev_user, class: User do
    sequence(:email) { |n| "dev+#{n}@gmail.com" }
    password "password"
    sequence(:name) {|n| "Developer #{n}"}
    before :create do |user|
      if Role.developer.blank?
        FactoryGirl.create(:developer_role)
      end
      user.roles << Role.developer
    end
  end
end
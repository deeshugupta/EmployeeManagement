FactoryGirl.define do

  factory :admin_role, class: Role do
    name 'admin'
  end

  factory :manager_role, class: Role do
    name 'Manager'
  end

  factory :developer_role, class: Role do
    name 'Developer'
  end
end
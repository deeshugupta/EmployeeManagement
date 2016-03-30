FactoryGirl.define do
  factory :casual, class: LeaveType do
    name 'Casual'
  end

  factory :sick, class: LeaveType do
    name 'Sick'
  end

  factory :privilege, class: LeaveType do
    name 'Privilege'
  end
end
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if LeaveType.count == 0
  LeaveType.create(:name => "Casual")
  LeaveType.create(:name => "Sick")
  LeaveType.create(:name => "Privilege")
end

if Role.count == 0
  [ {"working_days"=>nil, "name"=>"admin", "leaves_applicable"=>nil},
    {"working_days"=>5, "name"=>"Developer", "leaves_applicable"=>nil},
    {"working_days"=>6, "name"=>"Manager", "leaves_applicable"=>nil},
    {"working_days"=>5, "name"=>"QA", "leaves_applicable"=>nil},
    {"working_days"=>6, "name"=>"Designer", "leaves_applicable"=>nil}
  ].each do |attrs|
    Role.create attrs
  end
end

# checking and creating first admin user
admin = User.where(:email => "admin@traveltriangle.com").first
if admin.nil?
  admin = User.create email: 'admin@traveltriangle.com', password: 'password', password_confirmation: 'password'
  admin.roles << Role.admin
  admin.roles << Role.manager
else
  if !admin.is_admin?
    admin.roles << Role.admin
  end
  if !admin.is_manager?
    admin.roles << Role.manager
  end
end

# checking and creating developer main manager user
dev_manager = User.where(:email => "dev@traveltriangle.com").first
if dev_manager.nil?
  dev_manager = User.create email: 'dev@traveltriangle.com', password: 'password', password_confirmation: 'password', manager_id: admin.id
  dev_manager.roles << Role.manager
else
  if !dev_manager.is_manager?
    dev_manager.roles << Role.manager
  end
end

User.all.each do |user|
  is_changed = false
  if user.sick.nil?
    user.sick = 0
    is_changed = true
  end
  if user.privilege.nil?
    user.privilege = 0
    is_changed = true
  end
  if user.casual.nil?
    user.casual = 0
    is_changed = true
  end
  if is_changed
    user.save()
  end
end





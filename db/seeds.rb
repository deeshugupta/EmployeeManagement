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

# creating test managers
# (1..5).each do |i|
#   if User.where(:email => "manager+#{i}@traveltriangle.com").first.nil?
#     user = User.create email: "manager+#{i}@traveltriangle.com", password: 'password', password_confirmation: 'password', name: "Manager #{i}", manager_id: dev_manager.id
#     user.roles << Role.manager
#   end
# end

# creating test developers for each above manager
# Role.manager.users.each_with_index do |manager_user, i|
#   if manager_user.id != admin.id && manager_user.id != dev_manager.id
#     ((i * 40)..((i + 1) * 40)).each do |i|
#       if User.where(:email => "developer+#{i}@traveltriangle.com").first.nil?
#         user = User.create email: "developer+#{i}@traveltriangle.com", password: 'password', password_confirmation: 'password', name: "Developer #{i}", manager_id: manager_user.id
#         user.roles << Role.developer
#       end
#     end
#   end
# end

# if Holiday.where(:name => "Deepawali").first.nil?
#   Holiday.create(:name => "Deepawali", on_date: "2015-11-11", days: 2)
# end





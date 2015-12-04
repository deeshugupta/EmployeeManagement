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

if User.count == 0
  user = User.create email: 'admin@test.com', password: 'password', password_confirmation: 'password'
  user.roles << Role.first
end

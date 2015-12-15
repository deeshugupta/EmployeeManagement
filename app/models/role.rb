class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  # returns Role object for manager role
  def self.manager
    self.where(:name => "Manager").first
  end

  # returns Role object for admin role
  def self.admin
    self.where(:name => "admin").first
  end

  # returns Role object for developer role
  def self.developer
    self.where(:name => "Developer").first
  end


end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :manager_id, :join_date

  validates_presence_of :email
  validates_confirmation_of :password

  #Associations
  has_many :attendances
  has_many :team_members, :class_name => "User", :foreign_key => :manager_id
  belongs_to :manager, :class_name => "User"

  has_many :approvals, :through => :team_members, :source => :attendances

  has_and_belongs_to_many :roles
end

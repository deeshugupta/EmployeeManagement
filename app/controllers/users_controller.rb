class UsersController < ApplicationController

  def index
    @users = User.order(:name)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @managers = User.all(:include => :roles, :conditions => ["roles.name = ?", "Manager"])
    @roles_available = Role.all
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if params[:role].present?
      params[:role].each do |id|
        role = Role.find(id.to_i)
        @user.roles << role
      end
    else
      @user.roles << Role.find_by_name(:employee)
    end
    redirect_to root_path if @user.save!
  end


  def edit
    @user = User.find(params[:id])
    if @user.manager_id != current_user.id
      if !current_user.roles.include?Role.find_by_name(:admin)
        redirect_to "/404.html"
      end
    end
    @managers = User.all(:include => :roles, :conditions => ["roles.name = ?", "Manager"])
    @default_manager_name = @managers.first.name
    @default_manager_id = @managers.first.id

    @roles_available = Role.all
  end

  def update
    @user = User.find(params[:id])
    @user.roles.destroy_all
    if params[:role].present?
      params[:role].each do |id|
        role = Role.find(id.to_i)
        @user.roles << role
      end
    else
      @user.roles << Role.find_by_name(:employee)
    end

    if @user.update_attributes(params[:user])
      redirect_to users_path
    else
      @managers = User.all(:include => :roles, :conditions => ["roles.name = ?", "Manager"])
      @roles_available = Role.all
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end
end

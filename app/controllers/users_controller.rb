class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
  def index
    @users = User.all
  end
  def edit
    @user = User.find(params[:id])
    @managers = User.all(:include => :roles, :conditions => ["roles.name = ?", "Manager"])
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

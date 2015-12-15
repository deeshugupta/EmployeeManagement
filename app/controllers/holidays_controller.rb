class HolidaysController < ApplicationController
  before_filter :check_admin, except: :index

  def index
    @holidays = Holiday.all
  end

  def new
    @holiday = Holiday.new
  end

  def create
    @holiday = Holiday.new(params[:holiday])
    respond_to do |format|
      if @holiday.save
        format.html { redirect_to holidays_path }
        format.json { render json: @holiday, status: :created, location: @holiday }
      else
        format.html { render action: "new" }
        format.json { render json: @holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
    @holiday = Holiday.find(params[:id])
  end

  def update
    @holiday = Holiday.find(params[:id])
    respond_to do |format|
      if @holiday.update_attributes(params[:holiday])
        format.html { redirect_to holidays_path, notice: 'holiday was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @holiday.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @holiday = Holiday.delete(params[:id])
    redirect_to holidays_path, notice: 'holiday was successfully removed'
  end

  private

  def check_admin
    if !current_user.is_admin?
      redirect_to root_url
    end
  end
end

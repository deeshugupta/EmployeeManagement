class AttendancesController < ApplicationController
  # GET /attendances
  # GET /attendances.json
  # def index
  #   @attendances = Attendance.all
  #
  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.json { render json: @attendances }
  #   end
  # end

  # GET /attendances/1
  # GET /attendances/1.json
  def show
    @attendance = Attendance.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @attendance }
    end
  end

  # GET /attendances/1/edit
  def edit
    @attendance = Attendance.find(params[:id])
  end

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = Attendance.new(params[:attendance])
    @attendance.user = current_user
    @attendance.end_date= @attendance.start_date + @attendance.days.days

    respond_to do |format|
      if @attendance.save
        format.html { redirect_to :controller=> 'dashboard' }
        format.json { render json: @attendance, status: :created, location: @attendance }
      else
        format.html { render action: "new" }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /attendances/1
  # PUT /attendances/1.json
  def update
    @attendance = Attendance.find(params[:id])
    @attendance.end_date= @attendance.start_date + @attendance.days.days

    respond_to do |format|
      if @attendance.update_attributes(params[:attendance])
        format.html { redirect_to :controller=> 'dashboard', notice: 'Attendance was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendances/1
  # DELETE /attendances/1.json
  def destroy
    @attendance = Attendance.find(params[:id])
    if @attendance.destroy
      redirect_to :controller => 'dashboard', :notice => "Attendance Deleted successfully"
    end
  end
end

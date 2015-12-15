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

  def new
    @attendance = Attendance.new
    unless params[:old_id].blank?
      attendance = Attendance.find(params[:old_id]).attributes
      attendance.delete :id
      @attendance.attributes = attendance
    end
  end

  # GET /attendances/1/edit
  def edit
    @attendance = Attendance.find(params[:id])
    @leave_type = @attendance.leave_type
    if(@attendance.approval_status)
      redirect_to "/faultyaccess.html"
    end
  end

  # POST /attendances
  # POST /attendances.json
  def create
    @attendance = Attendance.new(params[:attendance])
    @attendance.emails_to_notify = @attendance.emails_to_notify.select{|email| !email.blank?}.join(",")
    @attendance.user = current_user
    @attendance.days = @attendance.days.abs
    if @attendance.days != 0.5
      @attendance.end_date= @attendance.start_date + @attendance.days.days - 1.days
    else
      @attendance.end_date= @attendance.start_date + @attendance.days.days - @attendance.days.days
    end
    if(@attendance.approval_status)
      redirect_to "/faultyaccess.html"
    end

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
    start_date = Date.new(params[:attendance]["start_date(1i)"].to_i, params[:attendance]["start_date(2i)"].to_i, params[:attendance]["start_date(3i)"].to_i)
    @attendance.start_date = start_date
    @attendance.end_date= start_date + params[:attendance][:days].to_i.abs.days - 1.days
    @attendance.approval_status =nil
    if(@attendance.approval_status)
      redirect_to "/faultyaccess.html"
    end

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
    if(@attendance.approval_status)
      redirect_to "/faultyaccess.html"
    end
    if @attendance.destroy
      redirect_to :controller => 'dashboard', :notice => "Attendance Deleted successfully"
    end
  end

  def apply_leave
    @attendance = Attendance.new
  end

  def team_leaves
    @manager = current_user
  end
end

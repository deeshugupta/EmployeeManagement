class DashboardController < ApplicationController

  def index
    @attendance = Attendance.new
  end
end

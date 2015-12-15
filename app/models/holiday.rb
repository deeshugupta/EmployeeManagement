class Holiday < ActiveRecord::Base


  def self.leave_dates_for_year(year)
    holidays = Holiday.where("YEAR(on_date)='#{year}'")
    leave_dates = []
    holidays.each do |holiday|
      leave_dates << holiday.on_date.upto(holiday.on_date + (holiday.days - 1).days).map{|dt| dt}
    end
    leave_dates.flatten
  end

  # day here must be of a date class instance
  def self.is_in_between_holiday?(day)
    return Holiday.leave_dates_for_year(Date.today.year).include?(day)
  end
end

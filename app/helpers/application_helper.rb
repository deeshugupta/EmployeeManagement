module ApplicationHelper
def date_format(date)
  date.strftime("%b %d, %Y")
end

  def available_leaves (join_date)
    current_date = DateTime.now.strftime("%b %d, %Y")
    dMonths = (current_date.year * 12 + current_date.month) - (join_date.year * 12 + join_date.month)

  end
end

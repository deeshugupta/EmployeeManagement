module RolesHelper

  def is_admin

    if current_user.roles.include?(Role.find_by_name(:admin))
      true
    else
      false
    end
  end
end

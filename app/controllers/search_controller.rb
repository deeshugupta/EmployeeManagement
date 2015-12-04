class SearchController < ApplicationController
  def search_emails
    skey = params["skey"]
    respond_to do |format|
      users = User.select("id, email").where("email LIKE '%#{skey}%'").as_json
      format.json{
      render :json => {items: users.to_json}
    }
    end
  end

  def search_name
    term = params["term"]
    respond_to do |format|
      users = User.select("id, name as label, name as value").where("name LIKE '%#{term}%'")
      format.json{
      render :json => users.to_json
    }
    end
  end
end

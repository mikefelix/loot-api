module ApplicationHelper

  def signed_in_user
    uid = session[:user_id]
    if uid
      User.find uid
    else
      nil
    end
  end

end

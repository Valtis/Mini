class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :image_owner_or_moderator?

  def is_logged_in
    current_user != nil
  end

  def current_user
    return nil if session[:user_id].nil?
    User.find(session[:user_id])
  end

  def image_owner_or_moderator?(image)
    current_user and (image.user == current_user or current_user.has_moderator_privileges)
  end

  def verify_image_owner_or_moderator(image)
    redirect_to images_path, notice: 'This operation is forbidden' unless image_owner_or_moderator?(image)
  end

end

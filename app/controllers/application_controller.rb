class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :image_owner_or_moderator?, :friendship_with_current_user, :has_right_to_see_image, :logged_in?,
                :comment_owner_or_moderator?, :can_modify_this_user_roles?

  def logged_in?
    current_user != nil
  end

  def current_user
    return nil if session[:user_id].nil?


    user = User.find(session[:user_id])
    if user.role == User::Role::BANNED
      session[:user_id] = nil
      return nil
    end

    return user
  end

  # can modify, if current_user has moderator\ədmin privileges and not modifying self
  # and if user is banned\regular. If user is moderator, only admins can modify
  def can_modify_this_user_roles?(user)
    if current_user.nil?
      return false
    end

    if current_user == user
      return false
    end

    if (current_user.has_admin_privileges?)
      return true
    end

    if current_user.has_moderator_privileges? and not user.has_moderator_privileges?
      return true
    end

    return false
  end


  def image_owner_or_moderator?(image)
    current_user and (image.user == current_user or current_user.has_moderator_privileges?)
  end

  def comment_owner_or_moderator?(comment)
    current_user and (comment.user == current_user or current_user.has_moderator_privileges?)
  end

  def verify_image_owner_or_moderator(image)
    redirect_to images_path, notice: 'This operation is forbidden' unless image_owner_or_moderator?(image)
  end

  def friendship_with_current_user(user)
    Friendship.friendship_for(current_user, user)
  end

  def has_right_to_see_image(image)
    # if image is public, image is uploaded by anonymous user, user is moderator/admin or user owns the image, then return true
    return true if image.visibility == Image::Visibility::PUBLIC or image.user.nil? or
        (current_user.nil? == false and (current_user.has_moderator_privileges? or image.user == current_user))

    # if user is nil and we reach this point, image is not public so return false
    return false if current_user.nil?

    # if visibility set to friends only and user is a friend of the image owner, return true
    return true if image.visibility == Image::Visibility::FRIENDS and current_user.is_friend_with(image.user)

    # otherwise, no rights to see the image
    false

  end

end

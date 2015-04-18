class Image < ActiveRecord::Base
  module Visibility
    PRIVATE = 0
    FRIENDS = 1
    PUBLIC = 2
  end


  belongs_to :album
  belongs_to :user
  has_many :comments

  has_attached_file :S3Image, styles: {
                               thumb: '100x100>',
                               medium: '300x300>'
                           }
  validates_attachment_content_type :S3Image, :content_type => /\Aimage\/.*\Z/

  validate :visibility_is_within_correct_range

  # could not figure out how to do this cleanly from scope, so use method instead
  def self.visible_images_for(request_user)
    Image.all.select{ |i| i.has_right_to_see_image(request_user) }
  end


  def visibility_is_within_correct_range
    if visibility.nil? or visibility < 0 or visibility > 2
      errors.add(:visibility, 'has invalid value')
    end
  end

  def has_right_to_see_image(request_user)
    # if image is public, image is uploaded by anonymous user, user is moderator/admin or user owns the image, then return true
    return true if visibility == Image::Visibility::PUBLIC or user.nil? or
        (request_user.nil? == false and (request_user.has_moderator_privileges? or user == request_user))

    # if user is nil and we reach this point, image is not public so return false
    return false if request_user.nil?

    # if visibility set to friends only and user is a friend of the image owner, return true
    return true if visibility == Image::Visibility::FRIENDS and request_user.is_friend_with(user)

    # otherwise, no rights to see the image
    false
  end

end

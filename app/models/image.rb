class Image < ActiveRecord::Base
  module Visibility
    PRIVATE = 0
    FRIENDS = 1
    PUBLIC = 2
  end

  belongs_to :user

  has_attached_file :S3Image, styles: {
                               thumb: '100x100>',
                               medium: '300x300>'
                           }
  validates_attachment_content_type :S3Image, :content_type => /\Aimage\/.*\Z/

  validate :visibility_is_within_correct_range

  def visibility_is_within_correct_range
    if visibility.nil? or visibility < 0 or visibility > 2
      errors.add(:visibility, 'has invalid value')
    end
  end

end

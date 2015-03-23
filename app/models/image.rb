class Image < ActiveRecord::Base
  belongs_to :user
  has_attached_file :S3Image, styles: {
                               thumb: '100x100>',
                               medium: '300x300>'
                           }
  validates_attachment_content_type :S3Image, :content_type => /\Aimage\/.*\Z/


end

class Album < ActiveRecord::Base

  has_many :images
  belongs_to :user

  validates :name, presence: true
  validates :user, presence: true
  validates :name, :uniqueness => {:scope => :user}

  def visible_images_for(request_user)
      images.all.select{ |i| i.has_right_to_see_image?(request_user) }
  end

end

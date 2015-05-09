class User < ActiveRecord::Base
  has_secure_password

  module Role
    NORMAL = 0
    BANNED = 1
    MODERATOR = 2
    ADMIN = 3
  end

  has_many :image
  has_many :albums
  has_many :comments

  has_many :pending_sent_requests, -> { where status: Friendship::Status::PENDING }, class_name: 'Friendship', foreign_key: 'requester_id'
  has_many :pending_received_requests, -> { where status: Friendship::Status::PENDING }, class_name: 'Friendship', foreign_key: 'friend_id'

  has_many :friends_as_requester, -> { where status: Friendship::Status::ACCEPTED }, class_name: 'Friendship', foreign_key: 'requester_id'
  has_many :friends_as_receiver, -> { where status: Friendship::Status::ACCEPTED }, class_name: 'Friendship', foreign_key: 'friend_id'


  validates :username, uniqueness: true, length: { minimum: 3, maximum: 15 }
  validates :password, length: { minimum: 8 }, unless: :skip_password_validation
  validate :password_contains_capital_letter_and_number, unless: :skip_password_validation
  validate :password_does_not_contain_username, unless: :skip_password_validation
  validate :role_has_valid_range

  attr_accessor :skip_password_validation


  def friends
    friendships = friends_as_requester + friends_as_receiver
    friends = []
    friendships.each do |f|
        if f.requester == self
          # if current user is the requester, add the friend to array
          friends << (f.friend)
        else
          #otherwise, add the requester to array
          friends << (f.requester)
        end
    end

    friends
  end

  def is_friend_with(user)
    friends.include? user
  end


  def password_contains_capital_letter_and_number
    if not password =~ /[A-Z]/ or not password =~ /[0-9]/
      errors.add(:password, 'must contain at least one capital letter and a number')
    end
  end

  def password_does_not_contain_username
    if password == nil or password.downcase.include? username.downcase
      errors.add(:password, 'must not contain username')
    end
  end


  def visible_images_for(request_user)
    image.all.select{ |i| i.has_right_to_see_image?(request_user) }
  end

  def role_has_valid_range
    if !role or role < 0 or role > 3
      errors.add(:role, 'has invalid value')
    end
  end


  def has_moderator_privileges?
    role == Role::MODERATOR or role == Role::ADMIN
  end

  def has_admin_privileges?
    role == Role::ADMIN
  end

  def role_string
    if role == Role::ADMIN
      return 'Admin'
    elsif role == Role::MODERATOR
      return 'Moderator'
    elsif role == Role::BANNED
      return 'Banned'
    else
      return 'Regular'
    end
  end

end

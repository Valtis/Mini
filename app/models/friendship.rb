class Friendship < ActiveRecord::Base
  module Status
    PENDING = 0
    ACCEPTED = 1
  end
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  #validates_uniqueness_of :friend_id, :scope => [:requester_id, :friend_id ]

  validates_presence_of :requester
  validates_presence_of :friend
  validate :friendship_does_not_exist
  validate :not_friend_with_self

  def not_friend_with_self
    if requester_id == friend_id
      errors.add(:friend_id, ' cannot be same as requester.')
    end
  end


  def self.friendship_for(user1, user2)
    Friendship.friendships_between(user1, user2).first
  end

  def friendship_does_not_exist
    # as far as I can tell, validations are handled inside transaction and rolled back in case of validation errors.
    # Thus, if we check friendship_for here, it always exists. Thus, we need to check that there are at most 1 friendship
    # (the one created inside the transaction we are currently validating for). If there are more, we had a pre-existing
    # friendship and need to bail out
    return if requester.nil? or friend.nil?
    unless Friendship.friendships_between(requester, friend).count <= 1
      errors.add(:requester_id, 'This friendship already exists')
    end
  end

  private
  def self.friendships_between(user1, user2)
    Friendship.where('(requester_id = ? AND friend_id = ?) OR (requester_id = ? AND friend_id = ?)',
                     user1.id, user2.id, user2.id, user1.id)
  end



end

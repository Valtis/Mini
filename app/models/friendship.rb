class Friendship < ActiveRecord::Base
  module Status
    PENDING = 0
    ACCEPTED = 1
  end
  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'

  validate :not_friend_with_self

  def not_friend_with_self
    if requester_id == friend_id
      errors.add(:friend_id, ' cannot be same as requester.')
    end
  end


  def self.friendship_for(user1, user2)
    Friendship.where('(requester_id = ? AND friend_id = ?) OR (requester_id = ? AND friend_id = ?)',
      user1.id, user2.id, user2.id, user1.id).first
  end
end

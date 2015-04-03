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

end

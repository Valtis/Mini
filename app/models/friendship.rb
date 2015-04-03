class Friendship < ActiveRecord::Base
  module Status
    PENDING = 0
    ACCEPTED = 1
  end

  belongs_to :requester, class_name: 'User', foreign_key: 'requester_id'
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'
end

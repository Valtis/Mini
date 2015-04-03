class Friendship < ActiveRecord::Base
  belongs_to :requester, :class_name => 'User', :foreign_key => 'requester_id'
  belongs_to :friend, :class_name => 'User', :foreign_key => 'friend_id'
end

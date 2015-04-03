class RenameFriendshipIdColumns < ActiveRecord::Migration
  def change
    rename_column :friendships, :requesterId, :requester_id
    rename_column :friendships, :friendID, :friend_id
  end
end

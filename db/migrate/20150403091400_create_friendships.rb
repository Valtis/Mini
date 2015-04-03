class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.integer :requesterId
      t.integer :friendID
      t.integer :status

      t.timestamps null: false
    end
  end
end

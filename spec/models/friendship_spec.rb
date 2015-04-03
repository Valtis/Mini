require 'rails_helper'

RSpec.describe Friendship, type: :model do
  before :each do
    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Foo'
  end

  it 'returns nil if users have no friendship' do
    expect(Friendship.friendship_for(@user, @buddy)).to be nil
  end

  it 'is returned if friendship exists between two users and status is pending' do
    Friendship.create requester: @user, friend: @buddy, status: Friendship::Status::PENDING
    expect(Friendship.friendship_for(@user, @buddy).is_a?(Friendship)).to be true
    expect(Friendship.friendship_for(@user, @buddy).requester).to eq @user
    expect(Friendship.friendship_for(@user, @buddy).friend).to eq @buddy

    # check that it works both ways
    expect(Friendship.friendship_for(@buddy, @user).requester).to eq @user
    expect(Friendship.friendship_for(@buddy, @user).friend).to eq @buddy
  end

  it 'is returned if friendship exists between two users and status is accepted' do
    Friendship.create requester: @user, friend: @buddy, status: Friendship::Status::ACCEPTED
    expect(Friendship.friendship_for(@user, @buddy).is_a?(Friendship)).to be true
    expect(Friendship.friendship_for(@user, @buddy).requester).to eq @user
    expect(Friendship.friendship_for(@user, @buddy).friend).to eq @buddy

    # check that it works both ways
    expect(Friendship.friendship_for(@buddy, @user).requester).to eq @user
    expect(Friendship.friendship_for(@buddy, @user).friend).to eq @buddy
  end
end
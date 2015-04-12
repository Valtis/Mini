require 'rails_helper'

RSpec.describe User, type: :model do


  it 'is created successfully with appropriate username, password and status' do
    user = FactoryGirl.create :user
    expect(user).to be_valid
    expect(user.authenticate('TestPassword1')).to be(user)
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('TestUser')
  end

  it 'is not authenticated with invalid password' do
    user = User.create username:'TestUser', password:'1TestPassword', password_confirmation:'1TestPassword', role: User::Role::NORMAL
    expect(user.authenticate('foo')).to be(false)
  end

  it 'is not created when username is too short' do
    user = User.create username:'t', password:'TestPassword1', password_confirmation:'TestPassword1',  role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when status code is invalid' do
    user = User.create username:'t', password:'TestPassword1', password_confirmation:'TestPassword1', role: -1
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when username is too long' do
    user = User.create username:'ReallyReallyReallyLongUsername', password:'TestPassword1', password_confirmation:'TestPassword1', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end


  it 'is not created if username already exists' do
    FactoryGirl.create :user
    user = User.create username:'TestUser', password:'TestPassword1', password_confirmation:'TestPassword1', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(1)
  end

  it 'is not created when password fields do not match' do
    user = User.create username:'TestUser', password:'TestPassword1', password_confirmation:'SOmethingsomethinfg', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password contains username' do
    user = User.create username:'TestUser', password:'TestPassword1ForTestUser', password_confirmation:'TestPassword1ForTestUser', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is missing numbers' do
    user = User.create username:'TestUser', password:'TestPassword', password_confirmation:'TestPassword', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is missing capital letters' do
    user = User.create username:'TestUser', password:'testpassword1', password_confirmation:'testpassword1', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is too short' do
    user = User.create username:'TestUser', password:'Foo1', password_confirmation:'Foo1', role: User::Role::NORMAL
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'does not have moderator privileges set when role is normal' do
    user = FactoryGirl.create :user, role: User::Role::NORMAL
    expect(user.has_moderator_privileges?).to be(false)
  end

  it 'does not have moderator privileges set when role is banned' do
    user = FactoryGirl.create :user, role: User::Role::BANNED
    expect(user.has_moderator_privileges?).to be(false)
  end

  it 'has moderator privileges set when role is moderator' do
    user = FactoryGirl.create :user, role: User::Role::MODERATOR

    expect(user.has_moderator_privileges?).to be(true)
  end

  it 'has moderator privileges set when role is admin' do
    user = FactoryGirl.create :user, role: User::Role::ADMIN
    expect(user.has_moderator_privileges?).to be(true)
  end

  it 'does not have moderator privileges set when role is normal' do
    user = FactoryGirl.create :user, role: User::Role::NORMAL
    expect(user.has_admin_privileges?).to be(false)
  end

  it 'does not have moderator privileges set when role is banned' do
    user = FactoryGirl.create :user, role: User::Role::BANNED
    expect(user.has_admin_privileges?).to be(false)
  end

  it 'has moderator privileges set when role is moderator' do
    user = FactoryGirl.create :user, role: User::Role::MODERATOR

    expect(user.has_admin_privileges?).to be(false)
  end

  it 'has moderator privileges set when role is admin' do
    user = FactoryGirl.create :user, role: User::Role::ADMIN
    expect(user.has_admin_privileges?).to be(true)
  end


  describe 'friendship' do
    before :each do
      @user = FactoryGirl.create :user
      @buddy = FactoryGirl.create :user, username: 'Foo'
      @buddy2 = FactoryGirl.create :user, username: 'Foobar'
    end

    it 'does not exist for new users' do
      expect(@user.pending_sent_requests.count).to eq 0
      expect(@user.pending_received_requests.count).to eq 0
      expect(@user.friends.length).to eq 0
    end

    it 'is false for new users' do
      expect(@user.is_friend_with(@buddy)).to eq false
      expect(@buddy.is_friend_with(@user)).to eq false
    end

    it 'request cannot be created multiple times' do

      request1 = Friendship.create requester: @user, friend: @buddy, status: Friendship::Status::PENDING

      expect(request1).to be_valid

      request2 = Friendship.create requester: @user, friend: @buddy, status: Friendship::Status::PENDING
      expect(request2).not_to be_valid

      request3 = Friendship.create requester: @buddy, friend: @user, status: Friendship::Status::PENDING
      expect(request3).not_to be_valid
    end

    it 'request increases pending sent and received counts but not friendship counts' do
      Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::PENDING

      expect(@user.pending_sent_requests.count).to eq 1
      expect(@user.pending_received_requests.count).to eq 0
      expect(@user.friends.length).to eq 0

      expect(@buddy.pending_sent_requests.count).to eq 0
      expect(@buddy.pending_received_requests.count).to eq 1
      expect(@buddy.friends.length).to eq 0

    end

    it 'is false for pending requests' do
      Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::PENDING
      expect(@user.is_friend_with(@buddy)).to eq false
      expect(@buddy.is_friend_with(@user)).to eq false
    end

    it 'cannot be requested with self' do
      Friendship.create requester_id: @user.id, friend_id: @user.id, status: Friendship::Status::PENDING
      expect(@user.pending_sent_requests.count).to eq 0
      expect(@user.pending_received_requests.count).to eq 0
      expect(@user.friends.length).to eq 0
    end

    it 'cannot be formed with self' do
      Friendship.create requester_id: @user.id, friend_id: @user.id, status: Friendship::Status::ACCEPTED
      expect(@user.pending_sent_requests.count).to eq 0
      expect(@user.pending_received_requests.count).to eq 0
      expect(@user.friends.length).to eq 0
    end

    it 'when accepted, increases friend count but not pending counts' do
      Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED

      expect(@user.pending_sent_requests.count).to eq 0
      expect(@user.pending_received_requests.count).to eq 0
      expect(@user.friends.length).to eq 1

      expect(@buddy.pending_sent_requests.count).to eq 0
      expect(@buddy.pending_received_requests.count).to eq 0
      expect(@buddy.friends.length).to eq 1
    end

    it 'when accepted, friends returns collection of friends' do
      Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED
      Friendship.create requester_id: @buddy2.id, friend_id: @user.id, status: Friendship::Status::ACCEPTED

      expect(@user.friends.length).to eq 2
      expect(@user.friends).to include(@buddy)
      expect(@user.friends).to include(@buddy2)
    end

    it 'is true for friends' do
      Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED

      expect(@user.is_friend_with(@buddy)).to eq true
      expect(@buddy.is_friend_with(@user)).to eq true
    end

  end


end

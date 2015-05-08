require 'rails_helper'
include CommonMethods

# this is a separate file due to the necessary configurations slowing down the tests to a crawl
describe 'User profile page with js' do

  before :all do
    self.use_transactional_fixtures = false
    WebMock.disable_net_connect!(allow_localhost:true)
  end


  before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start

    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Buddy'
    @stranger = FactoryGirl.create :user, username: 'stranger'
    @banned = FactoryGirl.create :banned
    @moderator = FactoryGirl.create :moderator
    @moderator2 = FactoryGirl.create :moderator, username: 'mode2'
    @admin = FactoryGirl.create :admin
    @admin2 = FactoryGirl.create :admin, username: 'Admin2'

    @private_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PRIVATE
    @friend_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::FRIENDS
    @public_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC

    @buddyfriendship=Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED
    @strangerfriendship=Friendship.create requester_id: @user.id, friend_id: @stranger.id, status: Friendship::Status::PENDING

  end


  after :each do
    DatabaseCleaner.clean
  end

  after :all do
    self.use_transactional_fixtures = true
  end
  
  it 'role change functionality works' , js:true do

    perform_login(@moderator.username, 'TestPassword1')

    visit user_path @stranger
    select 'Moderator', from: 'roleselect'
    expect(User.find(@stranger.id).role).to eq(User::Role::MODERATOR)

  end

end
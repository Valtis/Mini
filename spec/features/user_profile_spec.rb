require 'rails_helper'
include CommonMethods

describe 'User profile page' do

  before :each do

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



  it 'shows user name' do
    visit user_path @user
    expect(page).to have_content(@user.username)
  end


  it 'shows all images to user' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @user
    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end

  it 'shows all images to an admin' do
    perform_login(@admin.username, 'TestPassword1')
    visit user_path @user
    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end

  it 'shows only public images to anonymous user' do
    visit user_path @user
    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end

  it 'shows only public images to pending friend' do
    visit user_path @user
    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end


  it 'shows only public and friends-only images to friends user' do
    perform_login(@buddy.username, 'TestPassword1')
    visit user_path @user
    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end


  it 'shows regular status when user is a regular user' do
    visit user_path @user

    expect(page).to have_content('Regular')
    expect(page).not_to have_content('Banned')
    expect(page).not_to have_content('Moderator')
    expect(page).not_to have_content('Admin')
  end


  it 'shows ban status when user is banned' do
    visit user_path @banned

    expect(page).not_to have_content('Regular')
    expect(page).to have_content('Banned')
    expect(page).not_to have_content('Moderator')
    expect(page).not_to have_content('Admin')
  end


  it 'shows moderator status when user is a moderator' do
    visit user_path @moderator

    expect(page).not_to have_content('Regular')
    expect(page).not_to have_content('Banned')
    expect(page).to have_content('Moderator')
    expect(page).not_to have_content('Admin')
  end

  it 'shows moderator status when user is a moderator' do
    visit user_path @moderator

    expect(page).not_to have_content('Regular')
    expect(page).not_to have_content('Banned')
    expect(page).to have_content('Moderator')
    expect(page).not_to have_content('Admin')
  end

  it 'shows admin status when user is an admin' do
    visit user_path @admin

    expect(page).not_to have_content('Regular')
    expect(page).not_to have_content('Banned')
    expect(page).not_to have_content('Moderator')
    expect(page).to have_content('Admin')
  end


  it 'shows request friendship link for non-friends' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @admin
    expect(page).to have_button("Request friendship with #{@admin.username}")
  end

  it 'shows pending and accepted friendship requests for user' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @user

    expect(page).to have_link("#{@buddy.username}", href: user_path(@buddy))
    expect(page).to have_link("#{@stranger.username}", href: user_path(@stranger))

    expect(page).to have_link('Cancel friendship', href: reject_friendship_path(@buddyfriendship))
    expect(page).to have_link('Withdraw request', href: reject_friendship_path(@strangerfriendship))

  end

  it 'shows withdraw link for friendship when visiting pending friend page' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @stranger
    expect(page).to have_link('Cancel pending request', href: reject_friendship_path(@strangerfriendship))

  end

  it 'shows cancel link for friendship when visiting friend page' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @buddy
    expect(page).to have_link('Cancel friendship', href: reject_friendship_path(@buddyfriendship))


  end


  it 'shows accept and reject links when someone has requested friendship' do
    perform_login(@stranger.username, 'TestPassword1')
    visit user_path @stranger
    expect(page).to have_link('Accept friendship', href: accept_friendship_path(@strangerfriendship))
    expect(page).to have_link('Reject friendship', href: reject_friendship_path(@strangerfriendship))

  end


  it 'shows accept and reject links when visiting profile page of someone who has requested friendship' do
    perform_login(@stranger.username, 'TestPassword1')
    visit user_path @user

    expect(page).to have_link('Accept friendship', href: accept_friendship_path(@strangerfriendship))
    expect(page).to have_link('Reject friendship', href: reject_friendship_path(@strangerfriendship))

  end

  it 'can be used to accept friendship requests' do
    perform_login(@stranger.username, 'TestPassword1')
    visit user_path @stranger
    click_link('Accept friendship')
    expect(Friendship.find(@strangerfriendship.id).status).to eq(Friendship::Status::ACCEPTED)
  end

  it 'can be used to reject friendship requests' do
    perform_login(@stranger.username, 'TestPassword1')
    visit user_path @stranger
    click_link('Reject friendship')
    expect(Friendship.exists?(@strangerfriendship.id)).to eq(false)
  end

  it 'can be used to cancel friendships' do
    perform_login(@user.username, 'TestPassword1')
    visit user_path @user
    click_link('Cancel friendship')
    expect(Friendship.exists?(@buddyfriendship.id)).to eq(false)
  end

  it 'can be used to request friendship' do
    perform_login(@user.username, 'TestPassword1')
    expect(Friendship.count).to be(2)
    visit user_path @admin
    click_button("Request friendship with #{@admin.username}")
    expect(Friendship.count).to be(3)


    f = Friendship.last
    expect(f.requester).to eq(@user)
    expect(f.friend).to eq(@admin)
    expect(f.status).to eq(Friendship::Status::PENDING)
  end

  it 'when logged in as moderator has regular, banned and moderator roles listed for regular user' do
    perform_login(@moderator.username, 'TestPassword1')
    visit user_path @user
    expect(page).to have_select('roleselect', options: ['Regular', 'Banned', 'Moderator'])
  end


  it 'when logged in as moderator does not allow role change for self' do
    perform_login(@moderator.username, 'TestPassword1')
    visit user_path @moderator
    expect(page).not_to have_select('roleselect')
  end

  it 'when logged in as moderator does not allow role change of other moderator' do
    perform_login(@moderator.username, 'TestPassword1')
    visit user_path @moderator2
    expect(page).not_to have_select('roleselect')
  end

  it 'when logged in as admin, has regular, banned, admin and moderator roles listed for regular user' do
    perform_login(@admin.username, 'TestPassword1')
    visit user_path @user
    expect(page).to have_select('roleselect', options: ['Regular', 'Banned', 'Moderator', 'Admin'])
  end

  it 'when logged in as admin, has regular, banned, admin and moderator roles listed for moderators user' do
    perform_login(@admin.username, 'TestPassword1')
    visit user_path @moderator
    expect(page).to have_select('roleselect', options: ['Regular', 'Banned', 'Moderator', 'Admin'])
  end

  it 'when logged in as admin, has regular, banned, admin and moderator roles listed for another admin' do
    perform_login(@admin.username, 'TestPassword1')
    visit user_path @admin2
    expect(page).to have_select('roleselect', options: ['Regular', 'Banned', 'Moderator', 'Admin'])
  end


  it 'when logged in as admin does not allow change of own roles' do
    perform_login(@admin.username, 'TestPassword1')
    visit user_path @admin
    expect(page).not_to have_select('roleselect', options: ['Regular', 'Banned', 'Moderator', 'Admin'])
  end

end
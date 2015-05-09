require 'rails_helper'
include CommonMethods

describe 'Image page ' do
  before :each do
    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Buddy'
    @stranger = FactoryGirl.create :user, username: 'stranger'
    @moderator = FactoryGirl.create :moderator

    @private_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PRIVATE
    @friend_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::FRIENDS
    @public_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC

    Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED

  end

  it 'shows all images to owning user' do
    perform_login(@user.username, 'TestPassword1')
    visit images_path
    #image is not set, so we get text missing. This is fine

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end

  it 'shows public and friend images to user friend' do
    perform_login(@buddy.username, 'TestPassword1')
    visit images_path

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))

  end

  it 'shows only public images to stranger' do
    perform_login(@stranger.username, 'TestPassword1')
    visit images_path

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))

  end

  it 'shows all images to moderator' do
    perform_login(@moderator.username, 'TestPassword1')
    visit images_path

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
  end
end
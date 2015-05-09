require 'rails_helper'
include CommonMethods

describe 'Album page ' do
  before :each do
    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Buddy'
    @stranger = FactoryGirl.create :user, username: 'stranger'
    @moderator = FactoryGirl.create :moderator
    @admin = FactoryGirl.create :admin

    @album = Album.create name: 'AlbumName', user: @user

    @private_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PRIVATE, album: @album
    @friend_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::FRIENDS, album: @album
    @public_picture = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC, album: @album

    @non_album_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC
    @non_user_image = FactoryGirl.create :image, user: @stranger, visibility: Image::Visibility::PUBLIC

    Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED



  end

  it 'shows the album name' do
    visit album_path(@album)
    expect(page).to have_content(@album.name)
  end

  it 'shows no images after creation' do
    album = Album.create name: 'AlbumName123', user: @user
    visit album_path(album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).not_to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows all images that belongs to album to owner' do
    perform_login(@user.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))

  end


  it 'shows all images that belongs to album to moderator' do

    perform_login(@moderator.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end


  it 'shows all images that belongs to album to admin' do

    perform_login(@admin.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows only public image to anonymous user' do

    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows only public images to stranger' do

    perform_login(@stranger.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows public and friend images to friend' do
    perform_login(@buddy.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_picture))
    expect(page).to have_link('Missing', href: image_path(@public_picture))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

end
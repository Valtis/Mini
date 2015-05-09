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
    @friend_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::FRIENDS, album: @album
    @public_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC, album: @album

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

    expect(page).not_to have_content('Album has the following images')
    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_image))
    expect(page).not_to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows all images that belongs to album to owner' do
    perform_login(@user.username, 'TestPassword1')
    visit album_path(@album)


    expect(page).to have_content('Album has the following images')
    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))

  end


  it 'shows all images that belongs to album to moderator' do

    perform_login(@moderator.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end


  it 'shows all images that belongs to album to admin' do

    perform_login(@admin.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows only public image to anonymous user' do

    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows only public images to stranger' do

    perform_login(@stranger.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).not_to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'shows public and friend images to friend' do
    perform_login(@buddy.username, 'TestPassword1')
    visit album_path(@album)

    expect(page).not_to have_link('Missing', href: image_path(@private_image))
    expect(page).to have_link('Missing', href: image_path(@friend_image))
    expect(page).to have_link('Missing', href: image_path(@public_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_album_image))
    expect(page).not_to have_link('Missing', href: image_path(@non_user_image))
  end

  it 'allows owner to change name' do

    perform_login(@user.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).to have_link('Change album name', edit_album_path(@album))

    click_link('Change album name')

    fill_in('album_name', with: 'NewName')
    click_button('Update Album')

    expect(Album.find(@album.id).name).to eq('NewName')
  end

  it 'does not show edit link to stranger' do
    perform_login(@stranger.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).not_to have_link('Change album name', edit_album_path(@album))

  end

  it 'does not show edit link to moderator' do

    perform_login(@moderator.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).not_to have_link('Change album name', edit_album_path(@album))
  end

  it 'does not show edit link to admin' do

    perform_login(@admin.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).not_to have_link('Change album name', edit_album_path(@album))
  end

  it 'does not show edit link to anonymous' do
    visit album_path(@album)
    expect(page).not_to have_link('Change album name', edit_album_path(@album))
  end

  it 'has delete link if user owns the album' do
    perform_login(@user.username, 'TestPassword1')
    visit album_path(@album)
    expect(page).to have_link('Delete album', album_path(@album))
  end


  it 'allows owner to delete the album' do

    perform_login(@user.username, 'TestPassword1')
    visit album_path(@album)
    click_link('Delete album')

    expect(Album.exists?(@album.id)).to be(false)
    expect(Image.find(@private_image.id).album).to be(nil)
    expect(Image.find(@friend_image.id).album).to be(nil)
    expect(Image.find(@public_image.id).album).to be(nil)

  end

  it 'has no delete link if user does not own the album' do
    visit album_path(@album)
    expect(page).not_to have_link('Delete album', album_path(@album))
  end


end
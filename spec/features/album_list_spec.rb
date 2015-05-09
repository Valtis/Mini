require 'rails_helper'
include CommonMethods

describe 'Album list' do
  before :each do
    @user = FactoryGirl.create :user
    @user2 = FactoryGirl.create :user, username: 'foobar'

    @album = Album.create name: 'TestAlbum1', user: @user
    @album2 = Album.create name: 'TestAlbum2', user: @user
    @album3 = Album.create name: 'TestAlbum3', user: @user2
  end

  it 'lists all albums and their owners' do
    visit albums_path
    expect(page).to have_content("#{@album.name} #{@album.user.username}")
    expect(page).to have_content("#{@album2.name} #{@album2.user.username}")
    expect(page).to have_content("#{@album3.name} #{@album3.user.username}")
  end


  it 'has links to albums' do
    visit albums_path
    expect(page).to have_link("#{@album.name}", album_path(@album))
    expect(page).to have_link("#{@album2.name}", album_path(@album2))
    expect(page).to have_link("#{@album3.name}", album_path(@album3))
  end


  it 'has links to album owners' do
    visit albums_path
    expect(page).to have_link("#{@album.user.username}", user_path(@album.user))
    expect(page).to have_link("#{@album2.user.username}", album_path(@album2.user))
    expect(page).to have_link("#{@album3.user.username}", album_path(@album3.user))
  end

  it 'has link to new album creation if user is logged in' do
    perform_login(@user.username, 'TestPassword1')
    visit albums_path

    expect(page).to have_link('Create new album', new_album_path)
  end

  it 'can be used to create new album' do
    perform_login(@user.username, 'TestPassword1')
    visit albums_path

    click_link 'Create new album'

    fill_in('album_name', with: 'foobar')
    click_button('Create Album')
    visit albums_path
    new_album = Album.last
    expect(new_album.name).to eq('foobar')
    expect(new_album.user).to eq(@user)

    expect(page).to have_link("#{new_album.user.username}", album_path(new_album.user))

  end


  it 'does not have link to new album creation if user is not logged in' do
    visit albums_path
    expect(page).not_to have_link('Create new album', new_album_path)
  end
end
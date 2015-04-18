require 'rails_helper'

RSpec.describe Album, type: :model do

  before :each do
    @user = FactoryGirl.create :user
  end
  it 'is created successfully with name and user' do
    album = Album.create user: @user, name: 'hello'

    expect(Album.count).to eq(1)
    expect(album).to be_valid
    expect(album.user).to be(@user)
    expect(album.name).to eq('hello')
  end

  it 'cannot be created without user' do
    album = Album.create name: 'hello'

    expect(Album.count).to eq(0)
    expect(album).not_to be_valid
  end

  it 'cannot be created without name' do
    album = Album.create user: @user

    expect(Album.count).to eq(0)
    expect(album).not_to be_valid
  end

  it 'cannot be created if user already has album with same name' do

    album = Album.create user: @user, name: 'hello'
    album2 = Album.create user: @user, name: 'hello'

    expect(Album.count).to eq(1)
    expect(album).to be_valid
    expect(album2).not_to be_valid
  end

  it 'can be created with name if users are different' do
    user2 = FactoryGirl.create :user, username: 'asdasdsd'

    album = Album.create user: @user, name: 'hello'
    album2 = Album.create user: user2, name: 'hello'

    expect(Album.count).to eq(2)
    expect(album).to be_valid
    expect(album2).to be_valid
  end

  it 'contains all the images that belong to album' do

    album = Album.create user: @user, name: 'hello'
    different_album = Album.create user: @user, name: 'hello2'

    image1 = FactoryGirl.create :image
    image2 = FactoryGirl.create :image
    image3 = FactoryGirl.create :image
    image4 = FactoryGirl.create :image
    image5 = FactoryGirl.create :image

    album.images << image1
    album.images << image2
    album.images << image3
    different_album.images << image4
    different_album.images << image5

    expect(album.images.count).to eq(3)
    expect(album.images).to contain_exactly(image1, image2, image3)

    expect(different_album.images.count).to eq(2)
    expect(different_album.images).to contain_exactly(image4, image5)
  end


end

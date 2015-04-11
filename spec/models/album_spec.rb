require 'rails_helper'

RSpec.describe Album, type: :model do
  it 'is created successfully with name and user' do
    user = FactoryGirl.create :user
    album = Album.create user: user, name: 'hello'

    expect(Album.count).to eq(1)
    expect(album).to be_valid
    expect(album.user).to be(user)
    expect(album.name).to eq('hello')
  end

  it 'cannot be created without user' do
     album = Album.create name: 'hello'

    expect(Album.count).to eq(0)
    expect(album).not_to be_valid
  end

  it 'cannot be created without name' do
    user = FactoryGirl.create :user
    album = Album.create user: user

    expect(Album.count).to eq(0)
    expect(album).not_to be_valid
  end

  it 'cannot be created if user already has album with same name' do
    user = FactoryGirl.create :user

    album = Album.create user: user, name: 'hello'
    album2 = Album.create user: user, name: 'hello'

    expect(Album.count).to eq(1)
    expect(album).to be_valid
    expect(album2).not_to be_valid
  end

  it 'can be created with name if users are different' do
    user = FactoryGirl.create :user
    user2 = FactoryGirl.create :user, username: 'asdasdsd'
    album = Album.create user: user, name: 'hello'
    album2 = Album.create user: user2, name: 'hello'

    expect(Album.count).to eq(2)
    expect(album).to be_valid
    expect(album2).to be_valid
  end


end

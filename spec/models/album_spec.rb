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


end

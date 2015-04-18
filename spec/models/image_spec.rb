require 'rails_helper'

RSpec.describe Image, type: :model do
  it 'is created when visibility is 0' do
    image = FactoryGirl.create :image
    expect(image).to be_valid
    expect(Image.all.count).to eq(1)
  end

  it 'is not created when visibility is 3' do
    image = Image.create user: nil, album: nil, visibility: 3
    expect(image).not_to be_valid
    expect(Image.all.count).to eq(0)
  end


  it 'is not created when visibility is negative ' do
    image = Image.create user: nil, album: nil, visibility: -1
    expect(image).not_to be_valid
    expect(Image.all.count).to eq(0)
  end

  it 'is visible to owner when private' do
    owner = FactoryGirl.create :user
    image = FactoryGirl.create :image, user: owner, visibility: Image::Visibility::PRIVATE

    expect(image.has_right_to_see_image?(owner)).to eq(true)
  end

  it 'is visible to friend when visibility is set to friends only' do
    owner = FactoryGirl.create :user
    buddy = FactoryGirl.create :user, username: 'buddy'

    image = Image.create user: owner, album: nil, visibility: Image::Visibility::FRIENDS
    Friendship.create requester_id:  owner.id, friend_id: buddy.id, status: Friendship::Status::ACCEPTED

    expect(image.has_right_to_see_image?(buddy)).to eq(true)
  end

  it 'is not visible to friend when visibility is set to private' do
    owner = FactoryGirl.create :user
    buddy = FactoryGirl.create :user, username: 'buddy'

    image = Image.create user: owner, album: nil, visibility: Image::Visibility::PRIVATE
    Friendship.create requester_id:  owner.id, friend_id: buddy.id, status: Friendship::Status::ACCEPTED

    expect(image.has_right_to_see_image?(buddy)).to eq(false)
  end


  it 'is visible to anonymous user when visibility is public' do
    owner = FactoryGirl.create :user

    image = Image.create user: owner, album: nil, visibility: Image::Visibility::PUBLIC

    expect(image.has_right_to_see_image?(nil)).to eq(true)
  end

  it 'is not visible to anonymous user when visibility is set to friends only' do
    owner = FactoryGirl.create :user
    image = Image.create user: owner, album: nil, visibility: Image::Visibility::FRIENDS
    expect(image.has_right_to_see_image?(nil)).to eq(false)
  end

  it 'iis not visible to anonymous user when visibility is set to private' do
    owner = FactoryGirl.create :user

    image = Image.create user: owner, album: nil, visibility: Image::Visibility::PRIVATE

    expect(image.has_right_to_see_image?(nil)).to eq(false)
  end

  it 'is visible to moderator when visibility is set to private' do
    owner = FactoryGirl.create :user
    moderator = FactoryGirl.create :moderator
    image = Image.create user: owner, album: nil, visibility: Image::Visibility::PRIVATE

    expect(image.has_right_to_see_image?(moderator)).to eq(true)
  end

  it 'is visible to moderator when visibility is set to friends only' do
    owner = FactoryGirl.create :user
    moderator = FactoryGirl.create :moderator
    image = Image.create user: owner, album: nil, visibility: Image::Visibility::FRIENDS

    expect(image.has_right_to_see_image?(moderator)).to eq(true)
  end


  it 'is visible to moderator when visibility is set to public' do
    owner = FactoryGirl.create :user
    moderator = FactoryGirl.create :moderator
    image = Image.create user: owner, album: nil, visibility: Image::Visibility::PUBLIC

    expect(image.has_right_to_see_image?(moderator)).to eq(true)
  end


end

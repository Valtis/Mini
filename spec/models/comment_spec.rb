require 'rails_helper'

RSpec.describe Comment, type: :model do

  before :each do
    @user = FactoryGirl.create :user
    @image = FactoryGirl.create :image
  end

  it 'can be created with text, user and image' do
    comment = Comment.create user: @user, image: @image, text: 'Texttext'
    expect(comment).to be_valid
    expect(Comment.count).to be(1)
    expect(Comment.first).to eq (comment)
  end

  it 'can be created if text is empty (emptyposting is allowed)' do
    comment = Comment.create user: @user, image: @image
    expect(comment).to be_valid
    expect(Comment.count).to be(1)
    expect(Comment.first).to eq (comment)
  end

  it 'cannot be created if image is missing' do
    comment = Comment.create user: @user
    expect(comment).not_to be_valid
    expect(Comment.count).to be(0)
  end

  it 'cannot be created if user is missing' do
    comment = Comment.create image: @image
    expect(comment).not_to be_valid
    expect(Comment.count).to be(0)
  end



end

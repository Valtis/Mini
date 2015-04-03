require 'rails_helper'

RSpec.describe Friendship, type: :model do
  before :each do
    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Foo'
  end

  it 'does not exist for new users' do
    expect(@user.friendship.count).to eq 0
  end



end

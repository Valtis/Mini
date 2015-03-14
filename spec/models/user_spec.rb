require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is created successfully with appropriate username, password and status' do
    user = User.create username:'TestUser', password:'TestPassword1', password_confirmation:'TestPassword1', status: 0
    expect(user).to be_valid
    expect(user.authenticate('TestPassword1')).to be(user)
    expect(User.count).to eq(1)
    expect(User.first.username).to eq('TestUser')
  end

  it 'is not authenticated with invalid password' do
    user = User.create username:'TestUser', password:'1TestPassword', password_confirmation:'1TestPassword', status: 0
    expect(user.authenticate('foo')).to be(false)
  end

  it 'is not created when username is too short' do
    user = User.create username:'t', password:'TestPassword1', password_confirmation:'TestPassword1', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when status code is invalid' do
    user = User.create username:'t', password:'TestPassword1', password_confirmation:'TestPassword1', status: -1
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when username is too long' do
    user = User.create username:'ReallyReallyReallyLongUsername', password:'TestPassword1', password_confirmation:'TestPassword1', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password fields do not match' do
    user = User.create username:'TestUser', password:'TestPassword1', password_confirmation:'SOmethingsomethinfg', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password contains username' do
    user = User.create username:'TestUser', password:'TestPassword1ForTestUser', password_confirmation:'TestPassword1ForTestUser', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is missing numbers' do
    user = User.create username:'TestUser', password:'TestPassword', password_confirmation:'TestPassword', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is missing capital letters' do
    user = User.create username:'TestUser', password:'testpassword1', password_confirmation:'testpassword1', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'is not created when password is too short' do
    user = User.create username:'TestUser', password:'Foo1', password_confirmation:'Foo1', status: 0
    expect(user).not_to be_valid
    expect(User.count).to eq(0)
  end

  it 'has correct status after setting the status' do
    user = User.create username:'TestUser', password:'Foo1', password_confirmation:'Foo1', status: 0
    expect(user.user_status).to be(:normal)
    user.set_status(:banned)
    expect(user.user_status).to be(:banned)

    user.set_status(:admin)
    expect(user.user_status).to be(:admin)

    user.set_status(:moderator)
    expect(user.user_status).to be(:moderator)




  end
end

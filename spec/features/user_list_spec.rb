require 'rails_helper'
include CommonMethods

describe 'User list' do
  before :each do
    @user = FactoryGirl.create :user
    @banned_user = FactoryGirl.create :banned
    @moderator_user = FactoryGirl.create :moderator
    @admin_user = FactoryGirl.create :admin
  end

  describe 'when accessed by user' do
    it 'who is not logged in, is not shown' do
      visit users_path
      expect(current_path).to eq(root_path)
    end

    it 'who is logged in as normal user, is not shown' do
      perform_login(@user.username, 'TestPassword1')
      visit users_path
      expect(current_path).to eq(root_path)
    end

    it 'who is logged in as banned user, is not shown' do
      perform_login(@banned_user.username, 'TestPassword1')
      visit users_path
      expect(current_path).to eq(root_path)
    end

    it 'who is logged in as moderator user, is shown' do
      perform_login(@moderator_user.username, 'TestPassword1')
      visit users_path
      expect(current_path).to eq(users_path)
    end

    it 'who is logged in as admin user, is shown' do
      perform_login(@admin_user.username, 'TestPassword1')
      visit users_path
      expect(current_path).to eq(users_path)
    end
  end

  it 'shows all users when accessed by moderator' do
    perform_login(@moderator_user.username, 'TestPassword1')
    visit users_path
    expect(current_path).to eq(users_path)

    expect(page).to have_content('TestUser Regular')
    expect(page).to have_content('BannedUser Banned')
    expect(page).to have_content('AdminUser Admin')
    expect(page).to have_content('ModeratorUser Moderator')
  end

  it 'has links to user pages' do    perform_login(@moderator_user.username, 'TestPassword1')
    visit users_path
    expect(current_path).to eq(users_path)
    click_link('TestUser')
    expect(current_path).to eq user_path(@user)
  end


end
require 'rails_helper'

describe 'User' do
  before :each do
    @user = FactoryGirl.create :user
  end
  describe 'who has registered' do
    it 'can log in' do
      perform_login('TestUser', 'TestPassword1')
      expect(page).to have_content 'Welcome back TestUser!'
    end

    it 'is redirected to user page' do
      perform_login('TestUser', 'TestPassword1')
      expect(current_path).to eq(user_path(@user))
    end
  end

  describe 'who has not logged in' do
    it 'can create new user account' do
      create_account('AwesomeUser', 'AwesomePassword123','AwesomePassword123')

      expect(page).to have_content 'User was successfully created.'
      expect(current_path).to eq(user_path(User.all.last))
      expect(User.count).to eq(2)
    end

    it 'cannot create account if account info is invalid' do
      create_account('sh', 'shAwesomePassword1', 'aspkdj')
      expect(page).to have_content 'Password confirmation doesn\'t match Password'
      expect(page).to have_content 'Username is too short (minimum is 3 characters)'
      expect(page).to have_content 'Password must not contain username'
    end
  end

  describe 'who has logged in' do
    it 'is redirected back to root when trying to register new account' do
      perform_login('TestUser', 'TestPassword1')
      visit new_sessions_path
      expect(current_path).to eq(root_path)
    end
  end



  it 'is redirected back to log in page if username is wrong' do
    perform_login('TestSuer', 'TestPassword1')
    expect(page).to have_content 'Invalid username or password'
    expect(current_path).to eq(new_sessions_path)
  end

  it 'is redirected back to log in page if password is wrong' do
    perform_login('TestUser', 'TestPasswrd1')
    expect(page).to have_content 'Invalid username or password'
    expect(current_path).to eq(new_sessions_path)
  end

  it 'is redirected back to log in page if both username and password are wrong' do
    perform_login('asdffdsasadsf', 'adfsasda')
    expect(page).to have_content 'Invalid username or password'
    expect(current_path).to eq(new_sessions_path)
  end


  def perform_login(username, password)
    visit new_sessions_path
    click_link('Log in')
    fill_in('username', with: username)
    fill_in('password', with: password)
    click_button('Log in')
  end

  def create_account(username, password, password_confirm)
    visit new_user_path
    click_link('Register')

    fill_in('user_username', with: username)
    fill_in('user_password', with: password)
    fill_in('user_password_confirmation', with: password_confirm)

    click_button('Create User')

  end

end
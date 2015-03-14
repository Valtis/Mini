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
    visit root_path
    click_link('Log in')
    fill_in('username', with: username)
    fill_in('password', with: password)
    click_button('Log in')
  end

end
module CommonMethods

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
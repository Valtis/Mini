FactoryGirl.define do
  factory :user do
    username 'TestUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    role User::Role::NORMAL
  end

  factory :banned, class: :user do
    username 'BannedUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    role User::Role::BANNED
  end


  factory :moderator, class: :user do
    username 'ModeratorUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    role User::Role::MODERATOR
  end


  factory :admin, class: :user do
    username 'AdminUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    role User::Role::ADMIN
  end

end
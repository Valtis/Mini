FactoryGirl.define do
  factory :user do
    username 'TestUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    role User::Role::NORMAL
  end
end
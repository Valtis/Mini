FactoryGirl.define do
  factory :user do
    username 'TestUser'
    password 'TestPassword1'
    password_confirmation 'TestPassword1'
    status 0
  end
end
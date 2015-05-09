# separate file due to performance issues with db resets. Only tests requiring js are impactedrequire 'rails_helper'
require 'rails_helper'
require 'webmock/rspec'
include CommonMethods

describe 'Image page with js' do

  before :all do
    self.use_transactional_fixtures = false
    WebMock.disable_net_connect!(allow_localhost: true)

  end


  before :each do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
    @user = FactoryGirl.create :user

    @album = Album.create name: 'AlbumName', user: @user
    @album2 = Album.create name: 'AlbumName2: Electric boogaloo', user: @user

    @public_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC, album: @album
    @private_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PRIVATE



    perform_login(@user.username, 'TestPassword1')
    visit image_path @public_image
  end

  after :each do
    DatabaseCleaner.clean
  end

  after :all do
    self.use_transactional_fixtures = true
  end

  it 'can change image album' , js:true do

    select @album2.name, from: 'albumselect'
    sleep(1)
    expect(Image.find(@public_image.id).album).to eq(@album2)
  end


  it 'can set image album to None' , js:true do
    select 'None', from: 'albumselect'
    sleep(1)
    expect(Image.find(@public_image.id).album).to eq(nil)
  end

  it 'can set image visibility to private' , js:true do

    select 'private', from: 'visibilityselect'
    sleep(1)
    expect(Image.find(@public_image.id).visibility).to eq(Image::Visibility::PRIVATE)
  end


  it 'can set image visibility to friends' , js:true do
    select 'friends', from: 'visibilityselect'
    sleep(1)
    expect(Image.find(@public_image.id).visibility).to eq(Image::Visibility::FRIENDS)
  end


  it 'can set image visibility to public' , js:true do
    visit image_path @private_image
    select 'private', from: 'visibilityselect'
    sleep(1)
    expect(Image.find(@public_image.id).visibility).to eq(Image::Visibility::PUBLIC)
  end
end
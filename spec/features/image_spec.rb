require 'rails_helper'
include CommonMethods

describe 'Image page ' do
  before :each do
    @user = FactoryGirl.create :user
    @buddy = FactoryGirl.create :user, username: 'Buddy'
    @stranger = FactoryGirl.create :user, username: 'stranger'
    @moderator = FactoryGirl.create :moderator
    @admin = FactoryGirl.create :admin

    @album = Album.create name: 'AlbumName', user: @user
    @album2 = Album.create name: 'AlbumName2: Electric boogaloo', user: @user


    @private_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PRIVATE, album: @album
    @friend_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::FRIENDS, album: @album
    @public_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC, album: @album

    @non_album_image = FactoryGirl.create :image, user: @user, visibility: Image::Visibility::PUBLIC
    @anon_image = FactoryGirl.create :image, user: nil, visibility: Image::Visibility::PUBLIC

    @comment = Comment.create user: @buddy, image: @public_image, text: 'abcdefg'

    Friendship.create requester_id: @user.id, friend_id: @buddy.id, status: Friendship::Status::ACCEPTED
  end


  # somewhat questionable test since AWS depencencies are not mocked
  it 'has link to large image' do
    visit image_path @public_image
    expect(page).to have_link('Missing')
  end


  it 'handles owner views correctly' do
    perform_login(@user.username, 'TestPassword1')
    success_image_helper @public_image
    success_image_helper @friend_image
    success_image_helper @private_image
  end

  it 'handles moderator views correctly' do
    perform_login(@moderator.username, 'TestPassword1')
    success_image_helper @public_image
    success_image_helper @friend_image
    success_image_helper @private_image
  end

  it 'handles admin views correctly' do
    perform_login(@admin.username, 'TestPassword1')
    success_image_helper @public_image
    success_image_helper @friend_image
    success_image_helper @private_image
  end

  it 'handles strangers views correctly' do
    perform_login(@stranger.username, 'TestPassword1')
    success_image_helper @public_image
    fail_image_helper @friend_image
    fail_image_helper @private_image
  end

  it 'handles anonymous user views correctly' do
    perform_login(@stranger.username, 'TestPassword1')
    success_image_helper @public_image
    fail_image_helper @friend_image
    fail_image_helper @private_image
  end

  it 'handles friend user views correctly' do
    perform_login(@buddy.username, 'TestPassword1')
    success_image_helper @public_image
    success_image_helper @friend_image
    fail_image_helper @private_image
  end


  it 'contains uploader name if uploaded by registered user' do
    visit image_path @public_image
    expect(page).to have_content("Uploader: #{@public_image.user.username}")
  end

  it 'contains anonymous name if uploaded by anonymous user' do
    visit image_path @anon_image
    expect(page).to have_content('Uploader: Anonymous')
  end

  it 'has notification it belongs to album and link to album when part of album' do
    visit image_path @public_image


    expect(page).not_to have_content('Not part of any album')
    expect(page).to have_content("Part of album #{@public_image.album.name}")
    expect(page).to have_link("#{@public_image.album.name}", albums_path(@public_image.album))

  end

  it 'has notification it does not belong to album when not part of album' do
    visit image_path @non_album_image
    expect(page).not_to have_content('Part of album')
    expect(page).to have_content('Not part of any album')
  end

  it 'contains delete link for owner' do
    perform_login(@user.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).to have_link('Delete image', image_path(@public_image))
  end


  it 'allows owner to delete image' do
    perform_login(@user.username, 'TestPassword1')
    visit image_path @public_image
    click_link('Delete image')
    expect(Image.exists?(@public_image.id)).to eq(false)
    expect(Comment.count).to eq(0)
  end

  it 'contains delete link for moderator' do
    perform_login(@moderator.username, 'TestPassword1')

    visit image_path @public_image
    expect(page).to have_link('Delete image', image_path(@public_image))
  end

  it 'allows moderator to delete image' do
    perform_login(@moderator.username, 'TestPassword1')
    visit image_path @public_image
    click_link('Delete image')
    expect(Image.exists?(@public_image.id)).to eq(false)
    expect(Comment.count).to eq(0)
  end

  it 'contains delete link for admin' do
    perform_login(@admin.username, 'TestPassword1')

    visit image_path @public_image
    expect(page).to have_link('Delete image', image_path(@public_image))
  end

  it 'allows admin to delete image' do
    perform_login(@admin.username, 'TestPassword1')
    visit image_path @public_image
    click_link('Delete image')
    expect(Image.exists?(@public_image.id)).to eq(false)
    expect(Comment.count).to eq(0)
  end

  it 'does not contain delete link for stranger' do
    perform_login(@stranger.username, 'TestPassword1')

    visit image_path @public_image
    expect(page).not_to have_link('Delete image', image_path(@public_image))
  end

  it 'contains delete link for anonymous user' do
    visit image_path @public_image
    expect(page).not_to have_link('Delete image', image_path(@public_image))
  end

  it 'does not contain delete link for friend' do
    perform_login(@buddy.username, 'TestPassword1')

    visit image_path @public_image
    expect(page).not_to have_link('Delete image', image_path(@public_image))
  end

  it 'shows visibility and album select for owner' do
    perform_login(@user.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end

  it 'does not show visibility and album select to anonymous users' do
    visit image_path @public_image
    expect(page).not_to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).not_to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end

  it 'does not show visibility and album select to moderator users' do
    perform_login(@moderator.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).not_to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).not_to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end

  it 'does not show visibility and album select to admin users' do
    perform_login(@admin.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).not_to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).not_to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end

  it 'does not show visibility and album select to stranger users' do
    perform_login(@stranger.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).not_to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).not_to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end


  it 'does not show visibility and album select to friend users' do
    perform_login(@buddy.username, 'TestPassword1')
    visit image_path @public_image
    expect(page).not_to have_select('visibilityselect', options: ['public', 'friends', 'private'])
    expect(page).not_to have_select('albumselect', options: ['None', "#{@album.name}", "#{@album2.name}"])
  end

  describe 'comment section' do
    it 'shows comments' do
      visit image_path @public_image
      expect(page).to have_content("Comment by #{@comment.user.username}")
      expect(page).to have_content("#{@comment.text}")
    end

    it 'does not have create comment button for anonymous users' do

      visit image_path @public_image
      expect(page).not_to have_button('Create Comment')

    end

    it 'allows logged in user to create comments' do

      perform_login(@stranger.username, 'TestPassword1')
      visit image_path @public_image
      expect(page).to have_button('Create Comment')

      fill_in('comment_text', with: 'This is a test comment')
      click_button('Create Comment')

      expect(Comment.count).to eq(2)
      expect(page).to have_content("Comment by #{@stranger.username}")
      expect(page).to have_content('This is a test comment')
    end


    it 'allows logged in user to delete their comments' do

      perform_login(@stranger.username, 'TestPassword1')
      visit image_path @public_image
      expect(page).to have_button('Create Comment')

      fill_in('comment_text', with: 'This is a test comment')
      click_button('Create Comment')

      expect(page).to have_link('Delete comment', comment_path(Comment.last))
      click_link('Delete comment')
      expect(Comment.count).to be(1)
      expect(Comment.first.user).to eq(@buddy)
    end


    it 'allows moderators to delete comments' do

      perform_login(@moderator.username, 'TestPassword1')
      visit image_path @public_image

      expect(page).to have_link('Delete comment', comment_path(Comment.last))
      click_link('Delete comment')
      expect(Comment.count).to be(0)
    end

    it 'allows admins to delete comments' do

      perform_login(@admin.username, 'TestPassword1')
      visit image_path @public_image

      expect(page).to have_link('Delete comment', comment_path(Comment.last))
      click_link('Delete comment')
      expect(Comment.count).to be(0)
    end
  end

  def success_image_helper(image)
    visit image_path image
    expect(current_path).to eq(image_path(image))
  end

  def fail_image_helper(image)
    visit image_path image
    expect(current_path).to eq(root_path)
  end


end
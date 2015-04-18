require 'rails_helper'

RSpec.describe Image, type: :model do
  it 'is created when visibility is 0' do
    image = FactoryGirl.create :image
    expect(image).to be_valid
    expect(Image.all.count).to eq(1)
  end

  it 'is not created when visibility is 3' do
    image = Image.create user: nil, album: nil, visibility: 3
    expect(image).not_to be_valid
    expect(Image.all.count).to eq(0)
  end


  it 'is not created when visibility is negative ' do
    image = Image.create user: nil, album: nil, visibility: -1
    expect(image).not_to be_valid
    expect(Image.all.count).to eq(0)
  end

end

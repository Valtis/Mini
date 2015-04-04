class AddVisibilityToImage < ActiveRecord::Migration
  def change
    add_column :images, :visibility, :integer

    Image.all.each do |i|
      i.visibility = Image::Visibility::PRIVATE
      i.save
    end

  end
end

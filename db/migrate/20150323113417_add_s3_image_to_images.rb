class AddS3ImageToImages < ActiveRecord::Migration
  def self.up
    add_attachment :images, :S3Image
  end

  def self.down
    remove_attachment :images, :S3Image
  end
end

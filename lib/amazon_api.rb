
class AmazonApi
  def self.getInstance
    initialize unless @@s3Instance
    return @@s3Instance
  end



private
  def self.initialize
    data = JSON.load(File.read("config/s3.json"))
    creds = Aws::Credentials.new(data['AccessKeyId'], data['SecretAccessKey'])
    @@s3Instance = Aws::S3::Resource.new(credentials: creds, region: data['Region'])

  end


  @@s3Instance = nil
end
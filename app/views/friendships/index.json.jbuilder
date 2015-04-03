json.array!(@friendships) do |friendship|
  json.extract! friendship, :id, :requesterId, :friendID, :status
  json.url friendship_url(friendship, format: :json)
end

require_relative 'api_client/client'

class Location
  def self.fetch_coordinates(address)
    response = ApiClient::Client.fetch_location(address)
    location = response.dig("data", "searchPlaces", "results", 0, "place", "location")

    raise "Could not fetch coordinates for '#{address}'" unless location

    [location["latitude"], location["longitude"]]
  end
end

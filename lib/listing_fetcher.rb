require 'csv'
require 'date'
require_relative 'api_client'

module ListingFetcher
  API_URL = 'https://www.booking.com/dml/graphql'

  def self.fetch_coordinates(address)
    headers = ApiClient.build_headers
    payload = ApiClient.build_location_payload(address)
    response = ApiClient.fetch_from_api(API_URL, headers, payload)
    location = response.dig("data", "searchPlaces", "results", 0, "place", "location")
    raise "Could not fetch coordinates for '#{address}'" unless location
    [location["latitude"], location["longitude"]]
  end

  def self.fetch_properties(address, page_size, lat, lng, rad)
    headers = ApiClient.build_headers
    listings = []

    check_in = Date.today.strftime('%Y-%m-%d')
    check_out = (Date.today + 1).strftime('%Y-%m-%d')
    payload = ApiClient.build_search_body(address, page_size, check_in, check_out, lat, lng, rad)
    initial_response = ApiClient.fetch_from_api(API_URL, headers, payload)

    listings = extract_listing_data(initial_response)
    future_dates.each do |ci|
      co = (Date.parse(ci) + 1).strftime('%Y-%m-%d')
      monthly_payload = ApiClient.build_search_body(address, page_size, ci, co, lat, lng, rad)

      begin
        response = ApiClient.fetch_from_api(API_URL, headers, monthly_payload)
        results = response.dig('data', 'searchQueries', 'search', 'results') || []
        results.each do |result|
          id = result.dig('basicPropertyData', 'id')
          price = result.dig('priceDisplayInfoIrene', 'displayPrice', 'amountPerStay', 'amountUnformatted')
          listing = listings.find { |l| l[:id] == id }
          listing[:monthly_prices][ci] = price if listing
        end
      rescue => e
        puts "Failed to fetch for #{ci}: #{e.message}"
        listings.each { |l| l[:monthly_prices][ci] ||= nil }
      end
    end

    listings
  end

  def self.extract_listing_data(api_response)
    results = api_response.dig('data', 'searchQueries', 'search', 'results') || []
    results.map do |res|
      {
        id: res.dig('basicPropertyData', 'id'),
        title: res.dig('displayName', 'text'),
        page_name: res.dig('basicPropertyData', 'pageName'),
        base_price: res.dig('priceDisplayInfoIrene', 'displayPrice', 'amountPerStay', 'amountUnformatted'),
        monthly_prices: {}
      }
    end
  end

  def self.save_to_csv(listings, filename)
    months = future_dates
    headers = ['Listing ID', 'Title', 'Page Name', 'Base Price'] + months +
              ['Highest Price Date 1', 'Highest Price 1',
              'Highest Price Date 2', 'Highest Price 2',
              'Highest Price Date 3', 'Highest Price 3']

    CSV.open(filename, 'w', write_headers: true, headers: headers, encoding: 'UTF-8') do |csv|
      listings.each do |l|
        row = [l[:id], l[:title], l[:page_name], l[:base_price]]
        months.each { |date| row << l[:monthly_prices][date] }

        top_3 = l[:monthly_prices].select { |_, v| v }.sort_by { |_, v| -v.to_f }.first(3)
        top_3.each { |d, p| row << d << p }
        (3 - top_3.size).times { row << nil << nil }

        csv << row
      end
    end

    puts "Saved #{listings.size} listings to #{filename}"
  end

  def self.future_dates
    (0..11).map { |i| (Date.today >> i).strftime('%Y-%m-07') }
  end
end

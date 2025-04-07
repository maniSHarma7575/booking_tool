require 'date'
require_relative 'api_client/client'

module ListingFetcher
  def self.fetch_properties(address, page_size, lat, lng, radius)
    listings = []

    common_params = {
      address: address,
      page_size: page_size,
      lat: lat,
      lng: lng,
      rad: radius
    }

    today = Date.today
    check_in = today.strftime('%Y-%m-%d')
    check_out = (today + 1).strftime('%Y-%m-%d')

    initial_response = ApiClient::Client.search_hotels(
      **common_params,
      check_in: check_in,
      check_out: check_out
    )

    listings = extract_listings(initial_response)

    future_dates.each do |check_in_date|
      check_out_date = (Date.parse(check_in_date) + 1).strftime('%Y-%m-%d')

      begin
        response = ApiClient::Client.search_hotels(
          **common_params,
          check_in: check_in_date,
          check_out: check_out_date
        )

        results = response.dig('data', 'searchQueries', 'search', 'results') || []
        update_monthly_prices(listings, results, check_in_date)
      rescue => e
        puts "Failed to fetch for #{check_in_date}: #{e.message}"
        listings.each { |l| l[:monthly_prices][check_in_date] ||= nil }
      end
    end

    listings
  end

  def self.future_dates
    current_day = Date.today.day
    (0..11).map { |i| (Date.today >> i).strftime("%Y-%m-#{format('%02d', current_day)}") }
  end

  private

  def self.extract_listings(response)
    results = response.dig('data', 'searchQueries', 'search', 'results') || []
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

  def self.update_monthly_prices(listings, results, check_in_date)
    results.each do |result|
      id = result.dig('basicPropertyData', 'id')
      price = result.dig('priceDisplayInfoIrene', 'displayPrice', 'amountPerStay', 'amountUnformatted')
      listing = listings.find { |l| l[:id] == id }
      listing[:monthly_prices][check_in_date] = price if listing
    end
  end
end

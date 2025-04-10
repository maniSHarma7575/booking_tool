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

    listings
  end

  def self.fetch_prices_for_a_year_for_listing(listing)
    today = Date.today
    prices = {}
    page_name = listing[:page_name]
  
    (0..(365 / 60)).each do |chunk_index|
      start_date = today + (chunk_index * 60)
      fetched_prices = fetch_prices_for_range(start_date, page_name)
      prices.merge!(fetched_prices)
  
      # Sleep a little to avoid overwhelming the API
      puts "😴 Sleeping briefly before the next price fetch..."
      sleep(rand(0.5..1.0))
    end
  
    prices
  end

  def self.future_dates
    today = Date.today
    (0...365).map { |i| (today + i).strftime('%Y-%m-%d') }
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
      }
    end
  end

  def self.fetch_prices_for_range(start_date, page_name)
    prices = {}
    begin
      response = ApiClient::Client.fetch_property_prices(
        check_in: start_date.strftime('%Y-%m-%d'),
        pagename: page_name
      )

      days = response.dig('data', 'availabilityCalendar', 'days') || []

      days.each do |day|
        checkin = day['checkin']
        price = day['avgPrice']
        prices[checkin] = price
      end
      prices
    rescue => e
      puts "Failed to fetch prices for #{page_name} from #{start_date}: #{e.message}"
    end
  end
end

require_relative 'connection'
require_relative 'payload_builder'

module ApiClient
  class Client
    HEADERS = {
      'content-type' => 'application/json',
      'user-agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:136.0) Gecko/20100101 Firefox/136.0',
    }.freeze

    def self.search_hotels(address:, page_size:, check_in:, check_out:, lat:, lng:, rad:)
      payload = ApiClient::PayloadBuilder.search(
        address: address,
        page_size: page_size,
        check_in: check_in,
        check_out: check_out,
        lat: lat,
        lng: lng,
        rad: rad
      )
      Connection.post(headers: HEADERS, payload: payload)
    end

    def self.fetch_location(address)
      payload = ApiClient::PayloadBuilder.location(address)
      Connection.post(headers: HEADERS, payload: payload)
    end

    def self.fetch_property_prices(check_in:, pagename:, country_code: "us")
      payload = ApiClient::PayloadBuilder.availability(check_in: check_in, pagename: pagename, days: 60, country_code: country_code)
      Connection.post(headers: HEADERS, payload: payload)
    end
  end
end


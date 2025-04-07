require 'net/http'
require 'uri'
require 'json'

module ApiClient
  class Connection
    API_URL = URI('https://www.booking.com/dml/graphql').freeze

    def self.post(headers:, payload:)
      request = Net::HTTP::Post.new(API_URL.path, headers)
      request.body = payload.to_json

      response = Net::HTTP.start(API_URL.host, API_URL.port, use_ssl: true) do |http|
        http.request(request)
      end

      raise "HTTP #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
  end
end

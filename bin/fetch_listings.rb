#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/location'
require_relative '../lib/listing_fetcher'
require_relative '../lib/csv_exporter'

options = {
  radius: 3000,
  output: 'listings.csv'
}

OptionParser.new do |opts|
  opts.banner = "Usage: fetch_listings.rb -a ADDRESS [options]"

  opts.on("-a", "--address ADDRESS", "Address to search from") { |v| options[:address] = v }
  opts.on("-r", "--radius RADIUS", Integer, "Radius in meters") { |v| options[:radius] = v }
  opts.on("-o", "--output FILE", "Output CSV filename") { |v| options[:output] = v }
end.parse!

unless options[:address]
  puts "Address is required. Use -a or --address to specify it."
  exit 1
end

lat, lng = Location.fetch_coordinates(options[:address])
p "Coordinates for '#{options[:address]}': #{lat}, #{lng}"
p "Fetching listings within #{options[:radius]} meters of '#{options[:address]}'..."
listings = ListingFetcher.fetch_properties(options[:address], 50, lat, lng, options[:radius])
months = ListingFetcher.future_dates
CSVExporter.new(listings, options[:output], months).export

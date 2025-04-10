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
puts "Located coordinates for '#{options[:address]}': (#{lat}, #{lng})"

puts "Searching for listings within #{options[:radius]} meters of '#{options[:address]}'..."
listings = ListingFetcher.fetch_properties(options[:address], 50, lat, lng, options[:radius])

days = ListingFetcher.future_dates

if File.exist?(options[:output])
  File.delete(options[:output])
  puts "Removed existing output file: #{options[:output]}"
end

puts "Exporting listings and pricing data to #{options[:output]}..."

listings.each do |listing|
  prices = ListingFetcher.fetch_prices_for_a_year_for_listing(listing)
  listing[:daily_prices] = prices
  CSVExporter.new(listing, options[:output], days).export
end

puts "Export complete! Listings with pricing data saved to #{options[:output]}"
#!/usr/bin/env ruby

require 'optparse'
require_relative '../lib/listing_fetcher'

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

lat, lng = ListingFetcher.fetch_coordinates(options[:address])
listings = ListingFetcher.fetch_properties(options[:address], 50, lat, lng, options[:radius])
ListingFetcher.save_to_csv(listings, options[:output])
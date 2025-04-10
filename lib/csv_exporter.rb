require 'csv'

class CSVExporter
  def initialize(listing, filename, days)
    @listing = listing
    @filename = filename
    @days = days
  end

  def export
    headers = build_headers
    write_headers = !File.exist?(@filename) || File.zero?(@filename)

    CSV.open(@filename, 'a', write_headers: write_headers, headers: headers, encoding: 'UTF-8') do |csv|
      row = build_row(@listing)
      csv << row
    end

    puts "Saved #{@listing[:title]} prices to #{@filename}"
  end

  private

  def build_headers
    ['Listing ID', 'Title', 'Page Name', 'Base Price'] + @days +
    ['Highest Price Date 1', 'Highest Price 1',
     'Highest Price Date 2', 'Highest Price 2',
     'Highest Price Date 3', 'Highest Price 3']
  end

  def build_row(listing)
    row = [listing[:id], listing[:title], listing[:page_name], listing[:base_price]]
    @days.each { |date| row << listing[:daily_prices][date] }

    top_3 = listing[:daily_prices].select { |_, v| v }.sort_by { |_, v| -v.to_f }.first(3)
    top_3.each { |date, price| row << date << price }
    (3 - top_3.size).times { row << nil << nil }

    row
  end
end

require 'csv'

class CSVExporter
  def initialize(listings, filename, months)
    @listings = listings
    @filename = filename
    @months = months
  end

  def export
    headers = build_headers

    CSV.open(@filename, 'w', write_headers: true, headers: headers, encoding: 'UTF-8') do |csv|
      @listings.each do |listing|
        csv << build_row(listing)
      end
    end

    puts "Saved #{@listings.size} listings to #{@filename}"
  end

  private

  def build_headers
    ['Listing ID', 'Title', 'Page Name', 'Base Price'] + @months +
    ['Highest Price Date 1', 'Highest Price 1',
     'Highest Price Date 2', 'Highest Price 2',
     'Highest Price Date 3', 'Highest Price 3']
  end

  def build_row(listing)
    row = [listing[:id], listing[:title], listing[:page_name], listing[:base_price]]
    @months.each { |date| row << listing[:monthly_prices][date] }

    top_3 = listing[:monthly_prices].select { |_, v| v }.sort_by { |_, v| -v.to_f }.first(3)
    top_3.each { |date, price| row << date << price }
    (3 - top_3.size).times { row << nil << nil }

    row
  end
end

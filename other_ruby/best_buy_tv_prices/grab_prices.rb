# frozen_string_literal: true

require 'HTTParty'
require 'open-uri'
require 'nokogiri'

DEBUG = true

HEADERS = %i[
  url
  page
  store
  brand
  tech
  size
  resolution
  price
].freeze

URI_OPTIONS = {
  'User-Agent' => "Ruby/#{RUBY_VERSION}",
  'From' => 'spensterc@yahoo.com',
  'Referer' => 'http://www.ruby-lang.org/'
}.freeze

# Represent a possibly present value
class Maybe
  def self.nothing
    new(nil)
  end

  def self.just(val)
    new(val)
  end

  def initialize(val)
    @val = val.nil? ? { kind: :nothing } : { kind: :just, val: val }
  end

  def map
    thing = just? ? yield(val[:val]) : self
    thing.is_a?(Maybe) ? thing : Maybe.new(thing)
  end

  def or_else
    thing = just? ? self : yield
    thing.is_a?(Maybe) ? thing : Maybe.new(thing)
  end

  def get_or_else(other)
    just? ? val[:val] : other
  end

  def effect
    just? && yield(val[:val])
    self
  end

  def or_effect
    just? || yield
    self
  end

  def assign(name)
    return self unless just?
    return self.class.nothing unless val[:val].is_a?(Hash)

    other = yield(val[:val])
    other = other.is_a?(Maybe) ? other : Maybe.new(other)
    other.map { |ov| val[:val].merge(name => ov) }
  end

  private

  attr_reader :val

  def just?
    val[:kind] == :just
  end
end

def parse_at(doc, css_path)
  Maybe.new(doc.at(css_path))
end

def text_at(doc, css_path)
  parse_at(doc, css_path)
    .map(&:text)
    .or_effect { puts "Could not find text_at: #{css_path}" if DEBUG }
end

def parse_title(item, css_path)
  text_at(item, css_path)
    .get_or_else('')
end

def best_buy_title(item)
  parse_title(item, '.information .sku-title a')
end

def costco_title(item)
  parse_title(item, '.description a')
end

def amazon_title(item)
  parse_title(item, 'a @title')
end

def best_buy_ref(item)
  text_at(item, '.information .sku-title a @href')
end

def best_buy_url(item)
  best_buy_ref(item).map { |ref| "https://www.bestbuy.com#{ref}" }
end

def costco_url(item)
  text_at(item, '.description a @href')
end

def amazon_ref(item)
  text_at(item, 'a @href')
end

def amazon_url(item)
  amazon_ref(item)
    .map { |ref| ref.match?(/^https:/) ? ref : "https://www.amazon.com#{ref}" }
end

def best_buy_price(item)
  parse_at(item, '.price-block .priceView-hero-price.priceView-customer-price')
    .map { |prices| prices.children[1]&.text }
end

def costco_price(item)
  text_at(item, '.caption .price')
end

def amazon_price(item)
  text_at(item, '.a-offscreen')
    .or_effect { amazon_url(item).effect { |a| p a } }
end

def find_match(title, regex)
  Maybe.new(title.match(regex)).map(&:to_s)
end

def size_decoder(title)
  find_match(title, /\b\d+"/)
    .or_else { find_match(title, /\b\d+''/) }
    .or_else { find_match(title, /\b\d+”/) }
    .or_else { find_match(title, /\b\d+.?in/i) }
    .map { |s| s.match(/\d+/).to_s }
    .or_effect { puts "Could not decode size: #{title}" if DEBUG }
end

def tech_decoder(title)
  find_match(title, /\b[OQ]?LED\b/)
    .or_effect { puts "Could not decode tech: #{title}. Assuming LED" if DEBUG }
    .get_or_else('LED')
end

def resolution_decoder(title)
  find_match(title, /\b\d[Kk]\b/)
    .or_else { find_match(title, /\d+p/) }
    .or_effect { puts "Could not decode resolution: #{title}" if DEBUG }
end

def basic_attributes(title, store)
  Maybe
    .just({})
    .assign(:brand) { title.split(' ').first }
    .assign(:size) { size_decoder(title) }
    .assign(:tech) { tech_decoder(title) }
    .assign(:resolution) { resolution_decoder(title) }
    .map { |attrs| attrs.merge(store: store) }
end

def best_buy_attributes(item)
  basic_attributes(best_buy_title(item), 'Best Buy')
    .assign(:price) { best_buy_price(item) }
    .assign(:url) { best_buy_url(item) }
end

def costco_attributes(item)
  basic_attributes(costco_title(item), 'Costco')
    .assign(:price) { costco_price(item) }
    .assign(:url) { costco_url(item) }
end

def amazon_attributes(item)
  basic_attributes(amazon_title(item), 'Amazon')
    .assign(:price) { amazon_price(item) }
    .assign(:url) { amazon_url(item) }
end

def write_attrs(attrs, csv)
  csv << HEADERS.map { |key| attrs[key] }
end

def best_buy_write_list(list, page, csv)
  list.search('.sku-item').each do |item|
    best_buy_attributes(item)
      .effect { |attrs| write_attrs(attrs.merge(page: page), csv) }
  end
end

def costco_write_list(list, page, csv)
  list.search('.product').each do |item|
    costco_attributes(item)
      .effect { |attrs| write_attrs(attrs.merge(page: page), csv) }
  end
end

def amazon_write_list(list, page, csv)
  list.search('.s-result-item').each do |item|
    amazon_attributes(item)
      .effect { |attrs| write_attrs(attrs.merge(page: page), csv) }
  end
end

def get_doc(uri, store, page)
  cached_dir = 'cached_pages'
  store_dir = "#{cached_dir}/#{store}"

  Dir.mkdir(cached_dir) unless Dir.exist?(cached_dir)
  Dir.mkdir(store_dir) unless Dir.exist?(store_dir)

  path = "#{store_dir}/page_#{page}"

  unless File.readable?(path)
    URI.parse(uri).open(URI_OPTIONS) do |f|
      File.write(path, f.read)
    end
  end

  Nokogiri::HTML(File.read(path))
end

CSV.open('scraped_televisions.csv', 'wb') do |csv|
  csv << HEADERS

  best_buy_uri =
    'https://www.bestbuy.com/site/tvs/all-flat-screen-tvs/abcat0101001.c?qp=condition_facet%3DCondition~New'
  (1..12).each do |page|
    get_doc("#{best_buy_uri}&cp=#{page}", 'BestBuy', page)
      .search('.sku-item-list')
      .each { |list| best_buy_write_list(list, page, csv) }
  end

  costco_uri =
    'https://www.costco.com/televisions.html?display-type=led-lcd+oled&refine=ads_f110001_ntk_cs%253A%2522LED-LCD%2522|ads_f110001_ntk_cs%253A%2522OLED%2522|'
  parse_at(get_doc(costco_uri, 'Costco', 1), '.product-list.grid')
    .map { |list| costco_write_list(list, 1, csv) }

  amazon_uri =
    'https://www.amazon.com/s?i=electronics&bbn=172659&rh=n%3A172282%2Cn%3A493964%2Cn%3A1266092011%2Cn%3A172659%2Cp_72%3A1248879011%2Cp_n_condition-type%3A2224371011&dc&fst=as%3Aoff&rnid=2224369011'
  (1..14).each do |page|
    get_doc("#{amazon_uri}&page=#{page}&ref=sr_pg_#{page}", 'Amazon', page)
      .search('.s-result-list')
      .each { |list| amazon_write_list(list, page, csv) }
  end
end

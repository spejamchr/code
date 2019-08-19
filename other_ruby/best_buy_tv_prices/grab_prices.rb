# frozen_string_literal: true

# Get dependencies:
#
#   gem install httparty
#   gem install nokogiri
#   gem install parallel

require 'HTTParty'
require 'open-uri'
require 'nokogiri'
require 'Parallel'

DEBUG = false

HEADERS = %i[
  url
  page
  title
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

BEST_BUY_URI =
  'https://www.bestbuy.com/site/tvs/all-flat-screen-tvs/abcat0101001.c' \
  '?qp=condition_facet%3DCondition~New'

COSTCO_URI =
  'https://www.costco.com/televisions.html' \
  '?display-type=led-lcd+oled' \
  '&refine=ads_f110001_ntk_cs%253A%2522LED-LCD%2522|' \
  'ads_f110001_ntk_cs%253A%2522OLED%2522|'

AMAZON_URI =
  'https://www.amazon.com/Televisions-Television-Video/s' \
  '?i=electronics' \
  '&bbn=172659' \
  '&rh=n%3A172659%2Cp_72%3A1248879011%2Cp_n_condition-type%3A2224371011' \
  '&dc' \
  '&qid=1566078437' \
  '&rnid=2224369011' \
  '&ref=sr_nr_p_n_condition-type_1'

WALMART_URI =
  'https://www.walmart.com/search/api/preso' \
  '?facet=condition%3ANew%7C%7Cvideo_panel_design%3AFlat'

FRYS_URI =
  'https://www.frys.com/category/Outpost/Video/Televisions'

NEWEGG_URI =
  'https://www.newegg.com/p/pl?N=100167585%204814'

BEST_BUY_CONFIG = {
  store: 'Best Buy',
  base_url: 'https://www.bestbuy.com',
  list_query: '.sku-item-list',
  item_query: '.sku-item',
  title_query: '.information .sku-title a',
  price_query: '.price-block .priceView-hero-price.priceView-customer-price',
  url_query: '.information .sku-title a @href'
}.freeze

COSTCO_CONFIG = {
  store: 'Costco',
  base_url: 'https://www.costco.com',
  list_query: '.product-list',
  item_query: '.product',
  title_query: '.description a',
  price_query: '.caption .price',
  url_query: '.description a @href'
}.freeze

AMAZON_CONFIG = {
  store: 'Amazon',
  base_url: 'https://www.amazon.com',
  list_query: '.s-result-list',
  item_query: '.s-result-item',
  title_query: 'img @alt',
  price_query: '.a-offscreen',
  url_query: 'a @href'
}.freeze

FRYS_CONFIG = {
  store: 'Frys',
  base_url: 'https://www.frys.com',
  list_query: '#rightCol',
  item_query: '.product',
  title_query: '.productDescp a',
  price_query: '.toGridPriceHeight ul li .red_txt',
  url_query: '.productDescp a @href'
}.freeze

NEWEGG_CONFIG = {
  store: 'Newegg',
  base_url: 'https://www.newegg.com',
  list_query: '.items-view.is-grid',
  item_query: '.item-container',
  title_query: '.item-info .item-title',
  price_query: '.item-action .price-current',
  url_query: '.item-info a.item-title @href'
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

  def get_or_else(other)
    just? ? val[:val] : other
  end

  private

  attr_reader :val

  def just?
    val[:kind] == :just
  end
end

def map_maybe(maybes)
  return to_enum(:map_maybe, maybes) unless block_given?

  results = []
  maybes.each do |maybe|
    maybe.effect { |val| results << yield(val) }
  end
  results
end

def only_justs(maybes)
  map_maybe(maybes, &:itself)
end

# Utility methods for parsing TV string titles
module ParseTitle
  BRANDS = %w[
    ATYME AVERA AXESS CROWN ELEMENT FURRION GPX HISENSE HITACHI INSIGNIA JENSEN
    JVC KC LG MAGNAVOX NAXA PANASONIC PHILIPS PHILLIPS POLAROID PROSCAN PYLE
    RCA SAMSUNG SANYO SCEPTRE SEIKI SHARP SHARP SILO SKYWORTH SKYWORTH SONY
    SPELER SUNBRITE SUNBRITETV SUPERSONIC SÉURA TCL TOSHIBA VIEWSONIC VIZIO
    WESTINGHOUSE
  ].freeze

  private

  def find_match(title, regex)
    Maybe.new(title.match(regex)).map(&:to_s)
  end

  def brand_decoder(title)
    title = title.gsub(/[^a-z ]/i, '').upcase # Remove TM symbols

    Maybe
      .new((title.split(' ') & BRANDS).first)
      .or_effect { puts "Could not decode brand: #{title}" if DEBUG }
  end

  def size_decoder(title)
    # Explude any TVs in the single-digit size. Too small, and too easily
    # confused with other numbers (such as soundbar sizes).
    nums = /\d{2,}(\.\d{0,2})?/

    Maybe
      .nothing
      .or_else { find_match(title, /\b#{nums}["”']/) }
      .or_else { find_match(title, /\b#{nums}.?inch\b/i) }
      .or_else { find_match(title, /\b#{nums}.?in\b/i) }
      .or_else { find_match(title, /\b#{nums}.?Class/) }
      .map { |s| s.match(/#{nums}/).to_s }
      .or_effect { puts "Could not decode size: #{title}" if DEBUG }
  end

  def tech_decoder(title)
    find_match(title, /\b[OQUX]?LED\b/i)
      .or_else { find_match(title, /\bquantum\b/i).map { 'QLED' } }
      .or_effect { puts "Could not decode tech: #{title}" if DEBUG }
      .get_or_else('LED')
      .upcase
  end

  def k_to_p(nk_res)
    {
      '1k' => '1080p',
      '4k' => '2160p',
      '5k' => '2160p',
      '8k' => '4320p'
    }.fetch(nk_res.downcase)
  end

  def explicit_res_matcher(title)
    find_match(title, /\b\d+p\b/i)
  end

  def nk_matcher(title)
    find_match(title, /\b\dk\b/i)
      .map { |nk| k_to_p(nk) }
  end

  def uhd_matcher(title)
    Maybe
      .nothing
      .or_else { find_match(title, /\buhd\b/i).map { '2160p' } }
      .or_else { find_match(title, /\bultra hd\b/i).map { '2160p' } }
  end

  def hd_matcher(title)
    Maybe
      .nothing
      .or_else { find_match(title, /\bhd\b/i).map { '1080p' } }
      .or_else { find_match(title, /\bhdtv\b/i).map { '1080p' } }
      .or_else { find_match(title, /\bfhd\b/i).map { '1080p' } }
  end

  def nxn_matcher(title)
    find_match(title, /\d+.?x.?\d+/i).map { |s| "#{s.scan(/\d+/).last}p" }
  end

  def resolution_decoder(title)
    Maybe
      .nothing
      .or_else { explicit_res_matcher(title) }
      .or_else { nk_matcher(title) }
      .or_else { uhd_matcher(title) }
      .or_else { hd_matcher(title) }
      .or_else { nxn_matcher(title) }
      .map(&:downcase)
      .or_effect { puts "Could not decode resolution: #{title}" if DEBUG }
  end

  def basic_attributes(title)
    Maybe
      .just(title: title)
      .assign(:size) { size_decoder(title) }
      .assign(:resolution) { resolution_decoder(title) }
      .assign(:tech) { tech_decoder(title) }
      .assign(:brand) { brand_decoder(title) }
  end
end

# Parse TV info from an HTML page
class HtmlTvScraper
  include ParseTitle

  def initialize(**args)
    @store = args.fetch(:store)
    @base_url = args.fetch(:base_url)
    @list_query = args.fetch(:list_query)
    @item_query = args.fetch(:item_query)
    @title_query = args.fetch(:title_query)
    @price_query = args.fetch(:price_query)
    @url_query = args.fetch(:url_query)
  end

  def results(html, page)
    html
      .search(list_query)
      .map { |list| parse_list(list) }
      .map { |items| items.map { |attrs| attrs.merge(page: page) } }
  end

  private

  attr_reader(
    :store,
    :base_url,
    :list_query,
    :item_query,
    :title_query,
    :price_query,
    :url_query
  )

  def parse_at(doc, css_path)
    Maybe.new(doc.at(css_path))
  end

  def text_at(doc, css_path)
    parse_at(doc, css_path)
      .map(&:text)
      .or_effect { puts "Could not find text_at: #{css_path}" if DEBUG }
  end

  def parse_list(list)
    only_justs(list.search(item_query).map { |i| attributes(i) })
  end

  def safe_encode(string)
    string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
  end

  def item_title(item)
    text_at(item, title_query)
      .map { |s| safe_encode(s) }
      .get_or_else('')
      .gsub(/\s+/, ' ')
  end

  def item_url(item)
    text_at(item, url_query)
      .map { |ref| ref.match?(/^https?:/) ? ref : "#{base_url}#{ref}" }
  end

  def item_price(item)
    text_at(item, price_query)
      .map { |s| s.match(/\$[\d\,]+(\.\d\d)?/)&.to_s }
      .or_effect { item_url(item).effect { |a| p a if DEBUG } }
  end

  def attributes(item)
    basic_attributes(item_title(item))
      .assign(:store) { store }
      .assign(:price) { item_price(item) }
      .assign(:url) { item_url(item) }
  end
end

def write_attrs(attrs, csv)
  csv << HEADERS.map { |key| attrs[key] }
end

def get_doc(uri, store, page)
  cached_dir = 'cached_pages'
  store_dir = File.join(cached_dir, store)
  path = File.join(store_dir, "page_#{page}.html")

  Dir.mkdir(cached_dir) unless Dir.exist?(cached_dir)
  Dir.mkdir(store_dir) unless Dir.exist?(store_dir)

  unless File.readable?(path)
    URI.parse(uri).open(URI_OPTIONS) { |f| File.write(path, f.read) }
  end

  Nokogiri::HTML(File.read(path))
end

def get_json(uri, store, page)
  cached_dir = 'cached_pages'
  store_dir = File.join(cached_dir, store)
  path = File.join(store_dir, "page_#{page}.json")

  Dir.mkdir(cached_dir) unless Dir.exist?(cached_dir)
  Dir.mkdir(store_dir) unless Dir.exist?(store_dir)

  unless File.readable?(path)
    URI.parse(uri).open(URI_OPTIONS) { |f| File.write(path, f.read) }
  end

  JSON.parse(File.read(path))
end

def best_buy_results(uri)
  scraper = HtmlTvScraper.new(BEST_BUY_CONFIG)
  Parallel.map(1..12) do |page|
    scraper.results(get_doc("#{uri}&cp=#{page}", 'BestBuy', page), page)
  end.flatten
end

def costco_results(uri)
  HtmlTvScraper
    .new(COSTCO_CONFIG)
    .results(get_doc(uri, 'Costco', 1), 1)
    .flatten
end

def fetch_next_amazon_results(doc, page)
  text_at(doc, '#pagnNextLink @href')
    .or_else { text_at(doc, '.a-pagination .a-last a @href') }
    .map { |ref| ref.match?(/^https:/) ? ref : "https://www.amazon.com#{ref}" }
    .map { |new_uri| amazon_results(new_uri, page + 1) }
    .get_or_else([])
end

def fetch_amazon_results(uri, page = 1)
  doc = get_doc("#{uri}&page=#{page}&ref=sr_pg_#{page}", 'Amazon', page)
  results = HtmlTvScraper.new(AMAZON_CONFIG).results(doc, page)

  results + fetch_next_amazon_results(doc, page)
end

def use_cached_amazon_results(uri, pages)
  scraper = HtmlTvScraper.new(AMAZON_CONFIG)
  Parallel.map(1..pages) do |page|
    scraper.results(get_doc(uri, 'Amazon', page), page)
  end.flatten
end

def amazon_results(uri)
  cached_dir = 'cached_pages'
  store_dir = File.join(cached_dir, 'Amazon')
  if Dir.exist?(store_dir)
    pages = Dir[File.join(store_dir, '*')].count
    use_cached_amazon_results(uri, pages)
  else
    Dir.mkdir(cached_dir) unless Dir.exist?(cached_dir)
    Dir.mkdir(store_dir)

    fetch_amazon_results(uri)
  end
end

class WalmartScraper
  include ParseTitle

  def results(uri)
    Parallel.map(1..13) do |page|
      only_justs(
        get_json("#{uri}&page=#{page}", 'Walmart', page)['items']
        .map { |item| walmart_attributes(item) }
      ).map { |attrs| attrs.merge(page: page) }
    end.flatten
  end

  private

  def walmart_price(item)
    Maybe
      .new(item.dig('primaryOffer', 'offerPrice'))
      .or_effect { walmart_url(item).effect { |a| p a if DEBUG } }
  end

  def base_url
    'https://www.walmart.com'
  end

  def walmart_url(item)
    Maybe
      .new(item.dig('productPageUrl'))
      .map { |ref| ref.match?(/^https:/) ? ref : "#{base_url}#{ref}" }
  end

  def walmart_title(item)
    item.dig('title') || ''
  end

  def walmart_attributes(item)
    basic_attributes(walmart_title(item))
      .assign(:store) { 'Walmart' }
      .assign(:price) { walmart_price(item) }
      .assign(:url) { walmart_url(item) }
  end
end

def frys_results(uri)
  per = 20
  scraper = HtmlTvScraper.new(FRYS_CONFIG)
  Parallel.map(1..20) do |page|
    start = per * (page - 1)
    page_uri = "#{uri}?page=#{page}&start=#{start}&rows=#{per}"

    scraper.results(get_doc(page_uri, 'Frys', page), page)
  end.flatten
end

def newegg_results(uri)
  scraper = HtmlTvScraper.new(NEWEGG_CONFIG)
  Parallel.map(1..29) do |page|
    scraper.results(get_doc("#{uri}&page=#{page}", 'Newegg', page), page)
  end.flatten
end

def just_number(string)
  string.to_s.gsub(/[^\d\.]/, '').to_f
end

def sortable_array(hash)
  [
    just_number(hash[:size]),
    hash[:tech],
    just_number(hash[:resolution]),
    just_number(hash[:price]),
    *hash.values_at(:brand, :store, :page, :url)
  ]
end

results = []

results += best_buy_results(BEST_BUY_URI)
results += costco_results(COSTCO_URI)
results += amazon_results(AMAZON_URI)
results += WalmartScraper.new.results(WALMART_URI)
results += frys_results(FRYS_URI)
results += newegg_results(NEWEGG_URI)

results.sort_by! { |i| sortable_array(i) }

CSV.open('scraped_televisions.csv', 'wb') do |csv|
  csv << HEADERS

  results
    .group_by { |i| i[:url] }
    .values
    .map(&:first)
    .each { |attrs| write_attrs(attrs, csv) }
end

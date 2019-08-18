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

BRANDS = %w[
  ATYME
  AVERA
  AXESS
  CROWN
  ELEMENT
  FURRION
  GPX
  HISENSE
  HITACHI
  INSIGNIA
  JENSEN
  JVC
  KC
  LG
  MAGNAVOX
  NAXA
  PANASONIC
  PHILIPS
  PHILLIPS
  POLAROID
  PROSCAN
  PYLE
  RCA
  SAMSUNG
  SANYO
  SCEPTRE
  SEIKI
  SHARP
  SHARP
  SILO
  SKYWORTH
  SKYWORTH
  SONY
  SPELER
  SUNBRITE
  SUNBRITETV
  SUPERSONIC
  SÉURA
  TCL
  TOSHIBA
  VIEWSONIC
  VIZIO
  WESTINGHOUSE
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

def parse_at(doc, css_path)
  Maybe.new(doc.at(css_path))
end

def text_at(doc, css_path)
  parse_at(doc, css_path)
    .map(&:text)
    .or_effect { puts "Could not find text_at: #{css_path}" if DEBUG }
end

def safe_encode(string)
  string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
end

def parse_title(item, css_path)
  text_at(item, css_path)
    .map { |s| safe_encode(s) }
    .get_or_else('')
    .gsub(/\s+/, ' ')
end

def best_buy_title(item)
  parse_title(item, '.information .sku-title a')
end

def costco_title(item)
  parse_title(item, '.description a')
end

def amazon_title(item)
  parse_title(item, 'img @alt')
end

def walmart_title(item)
  item.dig('title') || ''
end

def frys_title(item)
  parse_title(item, '.productDescp a')
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

def walmart_ref(item)
  Maybe.new(item.dig('productPageUrl'))
end

def walmart_url(item)
  walmart_ref(item)
    .map { |ref| ref.match?(/^https:/) ? ref : "https://www.walmart.com#{ref}" }
end

def frys_ref(item)
  text_at(item, '.productDescp a @href')
end

def frys_url(item)
  frys_ref(item)
    .map { |ref| ref.match?(/^https:/) ? ref : "https://www.frys.com#{ref}" }
end

def best_buy_price(item)
  parse_at(item, '.price-block .priceView-hero-price.priceView-customer-price')
    .map { |prices| prices.children[1]&.text&.match(/\$.+/)&.to_s }
end

def costco_price(item)
  text_at(item, '.caption .price')
end

def amazon_price(item)
  text_at(item, '.a-offscreen')
    .or_effect { amazon_url(item).effect { |a| p a if DEBUG } }
end

def walmart_price(item)
  Maybe
    .new(item.dig('primaryOffer', 'offerPrice'))
    .or_effect { walmart_url(item).effect { |a| p a if DEBUG } }
end

def frys_price(item)
  text_at(item, '.toGridPriceHeight ul li .red_txt')
    .map { |t| t.gsub(/\s+/, '') }
    .or_effect { frys_url(item).effect { |a| p a if DEBUG } }
end

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
  nums = /[\d\.]+/

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

def basic_attributes(title, store)
  Maybe
    .just(title: title, store: store)
    .assign(:size) { size_decoder(title) }
    .assign(:resolution) { resolution_decoder(title) }
    .assign(:tech) { tech_decoder(title) }
    .assign(:brand) { brand_decoder(title) }
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

def walmart_attributes(item)
  basic_attributes(walmart_title(item), 'Walmart')
    .assign(:price) { walmart_price(item) }
    .assign(:url) { walmart_url(item) }
end

def frys_attributes(item)
  basic_attributes(frys_title(item), 'Frys')
    .assign(:price) { frys_price(item) }
    .assign(:url) { frys_url(item) }
end

def write_attrs(attrs, csv)
  csv << HEADERS.map { |key| attrs[key] }
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

def best_buy_parse_list(list)
  only_justs(list.search('.sku-item').map { |i| best_buy_attributes(i) })
end

def costco_parse_list(list)
  only_justs(list.search('.product').map { |i| costco_attributes(i) })
end

def amazon_parse_list(list)
  only_justs(list.search('.s-result-item').map { |i| amazon_attributes(i) })
end

def frys_parse_list(list)
  only_justs(list.search('.product').map { |i| frys_attributes(i) })
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
  Parallel.map(1..12) do |page|
    get_doc("#{uri}&cp=#{page}", 'BestBuy', page)
      .search('.sku-item-list')
      .map { |list| best_buy_parse_list(list) }
      .map { |items| items.map { |attrs| attrs.merge(page: page) } }
  end.flatten
end

def costco_results(uri)
  parse_at(get_doc(uri, 'Costco', 1), '.product-list')
    .map { |list| costco_parse_list(list) }
    .map { |items| items.map { |attrs| attrs.merge(page: 1) } }
    .get_or_else([])
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

  results =
    doc
    .search('.s-result-list')
    .map { |list| amazon_parse_list(list) }
    .map { |items| items.map { |attrs| attrs.merge(page: page) } }
    .flatten

  results + fetch_next_amazon_results(doc, page)
end

def use_cached_amazon_results(uri, pages)
  Parallel.map(1..pages) do |page|
    get_doc(uri, 'Amazon', page)
      .search('.s-result-list')
      .map { |list| amazon_parse_list(list) }
      .map { |items| items.map { |attrs| attrs.merge(page: page) } }
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

def walmart_results(uri)
  Parallel.map(1..13) do |page|
    only_justs(
      get_json("#{uri}&page=#{page}", 'Walmart', page)['items']
      .map { |item| walmart_attributes(item) }
    ).map { |attrs| attrs.merge(page: page) }
  end.flatten
end

def frys_results(uri)
  per = 20
  Parallel.map(1..20) do |page|
    start = per * (page - 1)
    page_uri = "#{uri}?page=#{page}&start=#{start}&rows=#{per}"

    get_doc(page_uri, 'Frys', page)
      .search('#rightCol')
      .map { |list| frys_parse_list(list) }
      .map { |items| items.map { |attrs| attrs.merge(page: page) } }
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
    hash[:brand],
    hash[:store],
    hash[:page],
    hash[:url]
  ]
end

results = []

results += best_buy_results(BEST_BUY_URI)
results += costco_results(COSTCO_URI)
results += amazon_results(AMAZON_URI)
results += walmart_results(WALMART_URI)
results += frys_results(FRYS_URI)

results.sort_by! { |i| sortable_array(i) }

CSV.open('scraped_televisions.csv', 'wb') do |csv|
  csv << HEADERS

  results
    .group_by { |i| i[:url] }
    .values
    .map(&:first)
    .each { |attrs| write_attrs(attrs, csv) }
end

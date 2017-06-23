# require 'rubygems'
require 'mechanize'

class Spider2
  attr_reader :visited_urls

  def initialize(start_url, max_depth = 1, url_filename = 'urls.txt')
    File.write(url_filename, '') # initilize empty file
    @agent = Mechanize.new
    @stack = UrlHash[start_url, 0]
    @visited_urls = []
    @max_depth = max_depth
    @url_filename = url_filename
  end

  def crawl
    s = Time.now
    work until @stack.count == 0
    puts Time.now - s
  end

  private

  def work
    url, depth = @stack.shift
    page = visit url
    return unless page
    File.write(@url_filename, url + "\n", mode: 'a')
    scrape(page, depth + 1) unless depth + 1 > @max_depth
  end

  def visit(url)
    @agent.get url
  rescue
    error('Could not visit page', url)
  end

  def scrape(page, depth)
    link_strings_for(page).each do |link_string|
      # already_visited_link = system("grep \"#{link_string}\" #{@url_filename}")
      already_visited_link = File.read(@url_filename) =~ %r{#{link_string}$}
      @stack[link_string] = depth unless already_visited_link
    end
  end

  def link_strings_for(page)
    links = links_for page
    link_strings = links.map do |link|
      begin
        link.uri.to_s
      rescue
        error('Could not load uri for link', link.href)
      end
    end
    link_strings.compact.uniq.select { |uri| uri =~ %r{^https?:\/\/} }
  end

  def links_for(page)
    page.links
  rescue
    error('Cannot get links for page', page.uri)
    []
  end

  def error(message, url)
    # puts "#{message}    #{url}"
  end

  class UrlHash < Hash
    def []=(arg, assign)
      return unless self[arg].nil?
      super(arg, assign)
    end
  end
end

# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 0) #=> 1 result (the original page)
# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 1) #=> 13 results
# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 2) #=> 111 results
# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 3) #=> 994 results
# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 4) #=> 155212 results
# s = Spider2.new('https://spencerchristiansen.wordpress.com/', 5) #=> ? results
# s.crawl

12.times do
  s = Spider2.new('https://spencerchristiansen.wordpress.com/', 1) #=> 13 results
  s.crawl
end

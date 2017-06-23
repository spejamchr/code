# require 'rubygems'
require 'mechanize'

# Crawl the web! :D
#
class Spider
  attr_reader :agent, :max_depth
  attr_accessor :todos, :urls, :depth

  def initialize(start_urls, max_depth = 2)
    @agent = Mechanize.new
    @todos = [start_urls].flatten.compact.uniq
    @urls = []
    @depth = 0
    @max_depth = max_depth
  end

  def crawl
    s = Time.now
    start
    puts "\nTook #{Time.now - s} seconds"
  end

  def start
    return if depth > max_depth
    scrape_urls
    self.depth += 1
    start
  end

  private

  def scrape_urls
    potential_new_targets = target_urls
    self.urls |= todos
    potential_new_targets -= urls
    self.todos = potential_new_targets
  end

  def target_urls
    todos.map { |todo| urls_from_page(todo) }.flatten.compact.uniq
  end

  def urls_from_page(url)
    return if urls.include?(url)

    begin
      page = agent.get(url)
      puts "d:#{depth} #{url}"
    rescue
      puts "    Could not load url: #{url}"
      @todos.delete(url)
      return
    end

    page_urls(page, url)
  end

  def page_urls(page, url)
    begin
      links = page.links
    rescue
      puts "    Cannot get links for page: #{page.uri}"
      @todos.delete(url)
      return []
    end
    link_strings = links.map do |link|
      begin
        link.uri.to_s
      rescue
        puts "    Could not load uri for link: #{link.href}"
      end
    end
    link_strings.select { |uri| uri =~ %r{^https?:\/\/} }.uniq
  end
end

# s = Spider.new('https://spencerchristiansen.wordpress.com/', 0) #=> 1 result (the original page)
# s = Spider.new('https://spencerchristiansen.wordpress.com/', 1) #=> 13 results
# s = Spider.new('https://spencerchristiansen.wordpress.com/', 2) #=> 111 results
# s = Spider.new('https://spencerchristiansen.wordpress.com/', 3) #=> 994 results
# s = Spider.new('https://spencerchristiansen.wordpress.com/', 4) #=> 155212 results
# s = Spider.new('https://spencerchristiansen.wordpress.com/', 5) #=> ? results
# s.crawl
#
# puts s.urls.count


12.times do
  s = Spider2.new('https://spencerchristiansen.wordpress.com/', 1) #=> 13 results
  s.crawl
end

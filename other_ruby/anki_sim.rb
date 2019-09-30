# Simulate a simple anki deck
class AnkiSim
  PUBLIC_ATTRIBUTES = %i(card_count new_per_day percent_correct sec_per_day).freeze

  STARTING_EASE = 2.5
  PASSED_EASE = 0.0
  FAILED_EASE = 0
  AVG_SEC = 24

  attr_accessor(*PUBLIC_ATTRIBUTES)

  attr_reader :reviews, :current_day, :mature_diffs, :max_news_per_day, :review_count_history, :new_count_history

  def initialize(options={})
    @clone_options = options.dup

    options[:sec_per_day] ||= 24 * 60 * 60
    @reviews = []
    @current_day = 0
    @mature_diffs = []
    @review_count_history = {}
    @new_count_history = {}

    PUBLIC_ATTRIBUTES.each { |a| self.send("#{a}=", options.fetch(a)) }

    @max_news_per_day = options.fetch(:new_per_day) if new_per_day

    self.new_per_day = rand_round(sec_per_day * percent_correct / AVG_SEC / (1 + percent_correct)) if sec_per_day && new_per_day.nil?
    self.new_per_day = [max_news_per_day, new_per_day].min if max_news_per_day
  end

  def sec_per_day=(num)
    @sec_per_day = num
    return if num.nil? && sec_per_day.nil?

    if sec_per_day
      self.new_per_day = 0
      new_time = sec_per_day - total_reviews_today * AVG_SEC
      if new_time > 0
        news_today = new_time * percent_correct / AVG_SEC / (1 + percent_correct)
        news_today = [news_today, max_news_per_day].min if max_news_per_day
        self.new_per_day = news_today.to_i
        self.new_per_day = [max_news_per_day, new_per_day].min if max_news_per_day
      end
    end
  end

  def daily_study_session(skip: false)
    if skip
      to_review = reviews.shift
      reviews[0] ||= []
      reviews[0] += to_review
      mature_diffs << 0
      @current_day += 1
      return
    end

    prev_mature_count = mature_count
    to_review = reviews.first || []
    if sec_per_day && sec_per_day < total_reviews_today * AVG_SEC
      reviews_today = rand_round(sec_per_day * percent_correct / AVG_SEC)
      limited_reviews = to_review.shift(reviews_today)
      reviews[1] ||= []
      reviews[1] += to_review
      to_review = limited_reviews
    end
    review(to_review) if to_review.count > 0
    reviews.shift
    learn
    mature_diffs << mature_count - prev_mature_count

    if sec_per_day
      self.new_per_day = 0
      new_time = sec_per_day - total_reviews_today * AVG_SEC
      if new_time > 0
        news_today = new_time * percent_correct / AVG_SEC / (1 + percent_correct)
        news_today = [news_today, max_news_per_day].min if max_news_per_day
        self.new_per_day = news_today.to_i
      end
    end
    @current_day += 1
  end

  def studied_count
    reviews.flatten.count
  end

  def sec_to_time_str(sec)
    hrs = sec.to_i / 3600
    min = (sec.to_i % 3600) / 60
    s = sec.to_i % 60
    "#{hrs}:#{min.to_s.rjust(2, '0')}:#{s.to_s.rjust(2, '0')}"
  end

  def simple_forecast(width=80)
    puts "Day #{current_day} (#{studied_count} cards)".to_s.center(width)
    puts '+' * width
    days_digits = reviews.count.to_s.length
    max = [reviews.max_by(&:count)&.count.to_i, 1].max
    count_digits = max.to_s.length

    reviews.each_with_index do |review_session, i|
      n = review_session.count
      day = (i + 1).to_s.rjust(days_digits) + '| '
      count = ' ' + n.to_s.rjust(count_digits)
      graph_space = width - day.length - count.length
      graph_length = (n / max.to_f * graph_space).round
      graph = (graph_length > 0 ? '-' * graph_length : (n.zero? ? '' : '.')).ljust(graph_space)

      seconds = n * AVG_SEC
      time = "(#{sec_to_time_str(seconds)})"

      puts day + graph + count + ' ' + time
    end

    puts
  end

  def clone
    self.class.new(**@clone_options)
  end

  def probable_max_card_attempts
    return @probable_max_card_attempts if defined? @probable_max_card_attempts

    a = clone
    a.daily_study_session until a.studied_count >= a.card_count
    @probable_max_card_attempts = a.max_review_session
  end

  def probable_days_to_see_all
    return @probable_days_to_see_all if defined? @probable_days_to_see_all

    a = clone
    a.daily_study_session until a.studied_count >= a.card_count
    @probable_days_to_see_all = a.current_day
  end

  def rand_round(n)
    f = n - n.floor
    up = rand < f
    up ? n.floor + 1 : n.floor
  end

  def total_reviews_today
    rand_round(reviews.first&.count.to_i / percent_correct)
  end

  def recorded_total_reviews_today
    rand_round(review_count_history.fetch(current_day - 1, 0) / percent_correct)
  end

  def new_card_tries_today
    rand_round(new_cards_today + new_cards_today / percent_correct)
  end

  def recorded_new_card_tries_today
    h = new_count_history.fetch(current_day - 1, 0)
    rand_round(h + h / percent_correct)
  end

  def total_time_today
    (total_reviews_today + new_card_tries_today) * AVG_SEC
  end

  def current_study_status(width: 80, day_width: 3, count_width: 3)
    day = (current_day - 1).to_s.rjust(day_width) + '| '

    r = recorded_total_reviews_today
    n = recorded_new_card_tries_today

    count = ' ' + (r + n).to_s.rjust(count_width)
    graph_space = width - day.length - count.length
    length_multiplier = graph_space / probable_max_card_attempts
    learn_length = (n * length_multiplier).round
    reviews_length = (r * length_multiplier).round
    learn = (learn_length > 0 ? '=' * learn_length : (n.zero? ? '' : ':'))
    review = (reviews_length > 0 ? '-' * reviews_length : (r.zero? ? '' : '.'))
    graph = (learn + review).ljust(graph_space)

    time = "(#{sec_to_time_str((r + n) * AVG_SEC)})"

    day + graph + count + ' ' + time + " N: " + "#{new_count_history.fetch(current_day - 1, 0)}".rjust(4) + " R: " + "#{review_count_history.fetch(current_day - 1, 0)}".rjust(4) + " U: " + "#{card_count - studied_count}".rjust(5)
  end

  def new_card
    { interval: 1, ease: STARTING_EASE }
  end

  def new_cards_today
    [new_per_day, card_count - studied_count].min
  end

  def learn
    new_count_history[current_day] = new_cards_today
    reviews << [] if reviews.empty?
    new_cards_today.times { reviews[0] << new_card }
  end

  def max_review_session
    # Divide by percent correct to account for viewing the same card multiple times (geometric series)
    review_count_history.transform_values { |r| r / percent_correct }
      .merge(new_count_history.transform_values { |n| n + n / percent_correct }) { |_, r, n| r + n }.values.max
  end

  def review(review_session)
    review_count_history[current_day] = review_session.count
    review_session.each do |card|
      passed = rand < percent_correct
      card[:ease] += passed ? PASSED_EASE : FAILED_EASE
      card[:interval] *= passed ? card[:ease] : 0.7
      next_day = [rand_round(card[:interval] + rand(3) - 1), 1].max
      card[:interval] = next_day
      reviews << [] until reviews.count > next_day
      reviews[next_day] << card
    end
  end

  def mature_count
    reviews.flatten.count { |c| c[:interval] > 21 }
  end

  def max_ease
    reviews.flatten.max_by { |r| [r[:ease], r[:interval]] }
  end

  def min_ease
    reviews.flatten.min_by { |r| [r[:ease], r[:interval]] }
  end
end

def new_deck(card_count: 1757, new_per_day: 20, percent_correct: 0.9, sec_per_day: nil)
  AnkiSim.new(
    card_count: card_count,
    new_per_day: new_per_day,
    percent_correct: percent_correct,
    sec_per_day: sec_per_day
  )
end


# # How long will it take for my input to equal my maturation output?
# throughput = 20
# a = new_deck(new_per_day: throughput)
# a.daily_study_session && puts(a.current_study_status) until a.mature_diffs.last&.>(throughput)
# a.simple_forecast
# puts a.mature_diffs.last
# puts a.mature_count

# How long with it take for all the cards to become mature?
# days = []
# iters = 100
# puts '_' * iters
# iters.times do
#   print '.'
#   a = new_deck(new_per_day: 20)
#   a.daily_study_session until a.mature_count == a.card_count
#   days << a.current_day
# end
# puts
# puts days.sum / iters.to_f

# # What will be the status after some number of days?
# a = new_deck(new_per_day: 20)
# days = (a.card_count / a.new_per_day).ceil + 2
# days.times { a.daily_study_session }
# puts a.reviews.first.count
# a.review(a.reviews.first)
# a.reviews.shift
# a.simple_forecast
# puts a.mature_count
# puts a.mature_diffs.inspect

# Record study progress history
a = new_deck(percent_correct: 0.9, new_per_day: 20)
# 70.times do
# a.daily_study_session
# puts a.current_study_status
# end

# 7.times do
# a.daily_study_session(skip: true)
# puts a.current_study_status
# end

# a.sec_per_day = a.probable_max_card_attempts * a.class::AVG_SEC
(a.probable_days_to_see_all + 3).times do
  a.daily_study_session
  puts a.current_study_status
end
# puts "min ease: #{a.min_ease}, max ease: #{a.max_ease}"

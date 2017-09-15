puts __FILE__

class ParseThing

  require 'csv'

  HEADERS = [
    'Unit',
    'BSA Member ID',
    'First Name',
    'Middle Name',
    'Last Name',
    'Advancement Type',
    'Advancement',
    'Version',
    'Date Completed',
    'Approved',
    'Awarded'
  ].map { |s| s.freeze }.freeze

  def initialize
    path = '/Users/spencer/Desktop/imports/Tammy Elliott/Scoutbook_Export1.csv'
    plaintext = File.read(path)
    csv = CSV.parse(plaintext)

    @headers = csv[0]
    @indices = @headers.each_with_object({}) { |e, o| o[e] = @headers.index(e) }
    @body = csv[1..-1]
  end

  def i(header)
    @indices[header]
  end

  def merit_badges
    all = @body.select { |r| r[i('Advancement Type')] =~ /Merit Badge/ }
    all.map! do |r|
      mb_info = r[i('Advancement')]
      mb, req = mb_info.split('#')
      mb = mb.strip
      if mb == 'Emergency Preparedness'
        if r[i('Version')].to_i >= 2016
          mb += ' (2016+)'
        else
          mb += ' (Retired)'
        end
      elsif mb == 'Nuclear Science'
        if r[i('Version')].to_i >= 2011
          mb += ' (2011+)'
        else
          mb += ' (Retired)'
        end
      elsif mb == 'Climbing'
        if r[i('Version')].to_i >= 2017
          mb += ' (2017)'
        else
          mb += ' (old)'
        end
      end
      r[i('Advancement')] = "#{mb.strip}#{req.nil? ? '' : '#' + req.strip}"
      r
    end
    all.map do |r|
      if r[i('Last Name')] == 'Farnum' && r[i('First Name')] == 'Greg'
        first_name = 'Gregory'
      else
        first_name = r[i('First Name')]
      end
      [
        r[i('Last Name')],
        first_name,
        r[i('Advancement')],
        DateTime.strptime(r[i('Date Completed')], '%m/%d/%Y').strftime('%Y-%m-%d'),
        nil,
      ]
    end
  end

  def ranks
    all = @body.reject { |r| r[i('Advancement Type')] =~ /Merit Badge/ }
    all.map! do |r|
      requirement_info = r[i('Advancement')].strip
      rank_info = r[i('Advancement Type')].chomp(' Rank Requirement').strip
      if requirement_info =~ /\A#\d+\D+\d+/
        requirement_info = /\A#\d+\D+/.match(requirement_info)[0]
      end
      r[i('Advancement')] = "#{rank_info}#{requirement_info}"
      r
    end
    all.map do |r|
      [
        r[i('Last Name')],
        r[i('First Name')],
        r[i('Advancement')],
        DateTime.strptime(r[i('Date Completed')], '%m/%d/%Y').strftime('%Y-%m-%d'),
        nil,
      ]
    end
  end

  def rank_headers
    %i(
      last_name
      first_name
      rank_advancement
      completed_on
      awarded_on
    )
  end

  def mb_headers
    %i(
      last_name
      first_name
      mb_advancement
      completed_on
      awarded_on
    )
  end

  def write
    CSV.open('/Users/spencer/Desktop/Tammy_mbs.csv', 'wb') do |csv|
      csv << mb_headers
      merit_badges.each { |mb| csv << mb }
    end

    CSV.open('/Users/spencer/Desktop/Tammy_ranks.csv', 'wb') do |csv|
      csv << rank_headers
      ranks.each { |mb| csv << mb }
    end
  end

end

#ParseThing.new.write

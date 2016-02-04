require 'mechanize'
require 'csv'
require 'pry'

require_relative 'subpage_strategies'

BASE_ADDRESS = 'https://en.wikipedia.org/wiki/List_of_companies_of_the_United_States_by_state'
SCAPE_DELAY = 1 # Wikipedia has a one page per second scrape limit
STATES = [ 'Alaska', 'Alabama', 'Arkansas', 'Arizona', 'California', 'Colorado', 'Connecticut', 
           'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Iowa', 'Idaho', 'Illinois', 'Indiana', 
           'Kansas', 'Kentucky', 'Louisiana', 'Massachusetts', 'Maryland', 'Maine', 'Michigan', 
           'Minnesota', 'Missouri', 'Mississippi', 'Montana', 'North Carolina', 'North Dakota', 
           'Nebraska', 'New Hampshire', 'New Jersey', 'New Mexico', 'Nevada', 'New York', 'Ohio', 
           'Oklahoma', 'Oregon', 'Pennsylvania', 'Rhode Island', 'South Carolina', 'South Dakota', 
           'Tennessee', 'Texas', 'Utah', 'Virginia', 'Vermont', 'Washington', 'Wisconsin', 
           'West Virginia', 'Wyoming' ]


puts 'Initiating scrape'

current_state = nil
companies_by_state = Hash.new {|h,k| h[k] = [] }
m = Mechanize.new

m.get(BASE_ADDRESS) do |usa_companies_page|
  usa_companies_page.css("div#mw-content-text")[0].children.each do |child_node| # loop through all child nodes of the main content container

    if child_node.name == 'h2' # set current state when we pass a state header
      state_name = child_node.children.css('span')[0].text
      if STATES.include?(state_name)
        current_state = state_name
        puts "Parsing #{current_state}"
      else
        current_state = nil
      end
    elsif current_state
      if child_node.matches?('div.hatnote') # if state has specific pages
        child_node.css('a').each do |a|
          m.transact do 
            url = a.attributes['href'].value
            strategy = STRATEGY_BY_URL[url]
            if strategy
              sleep(SCAPE_DELAY)
              companies_by_state[current_state] += send(STRATEGY_BY_URL[url], m, url) 
            end
          end
        end
      elsif child_node.matches?('ul') # if list is found
        child_node.css('li').each do |li| # get first link from each li
          a = li.css('a').first
          companies_by_state[current_state] << [a.text, a.attributes['href'].value]
        end
      end
    end

  end
end

print "Scrape complete, writing output..."

output_filename = "scraper_output_#{Time.now.to_i}.csv"
CSV.open(output_filename, 'w') do |out|
  out << ['name', 'state', 'url']
  STATES.each do |state|
    companies_by_state[state].each do |pair|
      out << [pair[0], state, pair[1]]
    end
  end
end

puts " wrote to #{output_filename}"


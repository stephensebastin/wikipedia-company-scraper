# hash rockets are dope, deal wit it
STRATEGY_BY_URL = { '/wiki/List_of_Alabama_companies' => :harvest_lis,
                    '/wiki/List_of_Alaska_companies' => :harvest_lis,
                    '/wiki/List_of_Arizona_companies' => nil,
                    '/wiki/List_of_Arkansas_companies' => :harvest_lis,
                    '/wiki/List_of_California_companies' => :harvest_lis,
                    '/wiki/List_of_Colorado_companies' => :harvest_lis,
                    '/wiki/List_of_Connecticut_companies' => :harvest_lis,
                    '/wiki/List_of_Delaware_companies' => :harvest_lis,
                    '/wiki/List_of_Florida_companies' => :harvest_lis,
                    '/wiki/List_of_Georgia_(U.S._state)_companies' => :harvest_lis,
                    '/wiki/List_of_companies_based_in_Idaho' => :harvest_lis,
                    '/wiki/List_of_Illinois_companies' => :harvest_lis,
                    '/wiki/List_of_Kansas_companies' => :harvest_lis,
                    '/wiki/List_of_Kentucky_companies' => :harvest_lis,
                    '/wiki/List_of_Michigan_companies' => :harvest_lis,
                    '/wiki/List_of_Minnesota_companies' => :harvest_lis,
                    '/wiki/List_of_New_York_companies' => :harvest_lis,
                    '/wiki/List_of_North_Dakota_companies' => :harvest_lis,
                    '/wiki/List_of_companies_based_in_Oklahoma_City' => :harvest_lis,
                    '/wiki/List_of_companies_based_in_Tulsa,_Oklahoma' => :harvest_lis,
                    '/wiki/List_of_companies_based_in_Oregon' => nil,
                    '/wiki/List_of_companies_based_in_Nashville' => :harvest_lis,
                    '/wiki/List_of_Texas_companies' => :harvest_lis,
                    '/wiki/List_of_Utah_companies' => nil,
                    '/wiki/List_of_companies_headquartered_in_Northern_Virginia' => :harvest_lis,
                    '/wiki/List_of_Washington_(state)_companies' => :harvest_lis,
                    '/wiki/List_of_Wyoming_companies' => nil } 

def harvest_lis(m, url)
  companies = []
  m.get(url) do |subpage|
    current_h2 = nil
    subpage.css("div#mw-content-text")[0].children.each do |child_node|
      if child_node.name == 'h2' # set current state when we pass a state header
        h2_text = child_node.children.css('span')[0].text
        if ['References', 'See also', 'See Also', 'Foreign companies'].include?(h2_text)
          current_h2 = 'invalid'
        else
          current_h2 = h2_text
        end

      elsif current_h2 != 'invalid'
        if child_node.matches?('ul') # if list is found
          child_node.css('li').each do |li| # get first link from each li
            next if li.attributes['class'] && li.attributes['class'].value == "mw-empty-li"

            a = li.css('a').first
            begin
              companies << [a.text, a.attributes['href'].value] if a
            rescue => e
              binding.pry
            end
          end
        end

      end
    end
  end
  return companies
end

$LOAD_PATH << File.dirname(__FILE__)

require 'web_tsunami'

# Triggers concurency the following requests:
# http://www.google.com
# http://www.google.com/search?q=ruby
# http://www.google.com/search?q=ruby&start=10

class GoogleTsunami < WebTsunami::Scenario
  def run
    get('http://www.google.com') do
      puts 'http://www.google.com'
      get('http://www.google.com/search?q=ruby') do
        puts 'http://www.google.com/search?q=ruby'
        get('http://www.google.com/search?q=ruby&start=10') do
          puts 'http://www.google.com/search?q=ruby&start=10'
        end
      end
    end
  end
end

GoogleTsunami.start(concurrency: 2, duration: 10)

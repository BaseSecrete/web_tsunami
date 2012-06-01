$LOAD_PATH << File.dirname(__FILE__)

require 'web_tsunami'

# Triggers the following requests concurently:
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

# Set concurrency and duration in seconds and start your script.
# These numbers are voluntary low because I don't want any trouble with Google.
# But don't hesitate to set a higher concurrency and a duration of almost 5 minutes
# in order to get a reliable benchmark.
GoogleTsunami.start(concurrency: 2, duration: 10)

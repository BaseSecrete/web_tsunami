# Web Tsunami

Write tailor-made scenarios for load testing web apps

## Why

Many good tools already exist for a very long time such as ApacheBench and Siege.
But, sometimes load testing a web app requires to write a custom scenario.
The goal is to focus only on the scenario without thinking about forking, threads and non blocking IOs.
Fortunately there is [Typhoeus](https://github.com/typhoeus/typhoeus) to send parallel HTTP requests.

Web Tsunami is a tiny class that forks every seconds and sends as many requests as expected.

## Example

```ruby
class Example < WebTsunami::Scenario
  def run
    get("http://site.example") do
      # Block is executed once the response has been received
      sleep(5) # Simulates the time required for a human to visit the next page
      get("http://site.example/search?query=stress+test") do |response|
        # Do whatever you need with the response object or ignore it
        sleep(10)
        get("http://site.example/search?query=stress+test&page=2") do
          sleep(5)
          get("http://site.example/stress/test")
        end
      end
    end
  end
end

# Simulates 100 concurrent visitors every second for 10 minutes
# It's a total of 60K unique visitors for an average of 23'220 rpm.
Example.start(concurrency: 100, duration: 60 * 10)
```

In this example, the same requests are always sent.
But you can provide dynamic query strings, use variables and some randomness.

## Output and result

Web Tsunami does not measure response time or print any result.
If you are running a load test, that means you should use an APM (application performance monitoring).
It already collects and displays all data you need such as throughput, response time and bottlenecks.

So, the only output are errors.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Rails developer? Check out [RoRvsWild](https://rorvswild.com), our Ruby on Rails application monitoring tool.

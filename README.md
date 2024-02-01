<img align="right" width="120px" src="./web_tsunami.png">

# Web Tsunami

Write tailor-made scenarios for load testing web apps

## Why

Many good tools already exist for a very long time such as ApacheBench and Siege.
The goal is not to replace them.
But sometimes, load testing a web app requires to write a custom scenario.
My initial requirement was to send requests with unique parameters.
To the best of my knowledge, no tool could do this.

The goal is to focus only on the scenario without thinking about forking, threads and non blocking IOs.
Fortunately there is [Typhoeus](https://github.com/typhoeus/typhoeus) to send parallel HTTP requests.

## How

Web Tsunami is a tiny class that forks every seconds and sends as many requests as expected.
It provide the methods `get`, `post`, `put`, `patch` and `delete`.
They all accept the same arguments : `get(url, options = {}, &block)`.
The `options` is given to Typhoeus as is.
It can contain headers and the request body.
See [Typhoeus usage](https://github.com/typhoeus/typhoeus/#usage) for more details.

## Examples

Let's start with a very trivial scenario and I will show you an advanced one after :

```ruby
require "web_tsunami"

class SearchTsunami < WebTsunami::Scenario
  def run
    get("http://site.example") do
      # Block is executed once the response has been received
      sleep(5) # Simulates the time required for a human to visit the next page
      get("http://site.example/search?query=stress+test") do |response|
        # Do whatever you need with the response object or ignore it
        sleep(10)
        get("http://site.example/search?query=stress+test&page=#{rand(100)}") do
          sleep(5)
          get("http://site.example/stress/test")
        end
      end
    end
  end
end

# Simulates 100 concurrent visitors every second for 10 minutes
# It's a total of 60K unique visitors for an average of 23'220 rpm.
SearchTsunami.start(concurrency: 100, duration: 60 * 10)
```

In this scenario, a visitor comes on the index page, then search for _stress test_, then go on a random page of the search result, and finally found the stress test page.
It introduces a unique parameters which is the page number.
It's nice, but it could have almost be done with Siege.
Let me show you a more realistic scenario.

```ruby
require "web_tsunami"

class SessionTsunami < WebTsunami::Scenario
  def run
    # The session object stores cookies and automatically submit CSRF token with forms
    session = WebTsunami::Session.new(self, "https://site.example")
    session.get("/") do
      session.get("/account/new") do
        # An authenticity_token param is automatically added by the session
        session.post("/account", body: {account: "#{rand(1000000)}@email.test", password: "password"}}) do |response|
          # The session stores the Set-Cookie header and will provide it to the next requests
          session.get("/dashboard") do # Redirection after registration
            # And so on
          end
        end
      end
    end
  end
end

SessionTsunami.start(concurrency: 100, duration: 60 * 10)
```

This is more realistic because it handles CSRF tokens and cookies.
Thus the scenario can submit forms and behaves a little bit more like a real visitor.

## Output and result

Web Tsunami does not measure response time or print any result.
If you are running a load test, that means you should use an APM (application performance monitoring).
It already collects and displays all data you need such as throughput, response time and bottlenecks.

So, the only output are errors.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Rails developer? Check out [RoRvsWild](https://rorvswild.com), our Ruby on Rails application monitoring tool.

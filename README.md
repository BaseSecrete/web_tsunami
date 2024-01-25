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
Let me show you a more advanced scenario.

```ruby
require "web_tsunami"
require "json"

class RegistrationTsunami < WebTsunami::Scenario
  # Simulate a visitor coming on the index page,
  # then going to the registration form,
  # and finally submitting the form.
  def run
    get("http://site.example/") do |response|
      get("http://site.example/account/new") do |response|
        post("http://site.example/account", post_account_options(response)) do |response|
          # Then visiting the dashboard, and so on.
        end
      end
    end
  end

  private

  def post_account_options(response)
    # In order to not be blocked by the Cross-Site Request Forgery, the request must contain :
    #   1. Cookie header
    #   2. authenticity_token form param
    {
      headers: build_post_headers(response),
      body: JSON.generate(
        authenticity_token: extract_csrf_token(response.body),
        user: {
          name: name = rand.to_s[2..-1],
          email: "#{name}@domain.test",
          password: name,
        }
      ),
    }
  end

  def build_post_headers(response)
    {
      "Origin" => response.request&.base_url,
      "Content-Type" => "application/json",
      "Cookie" => response.headers["Set-Cookie"],
      # To Simulate a post XmlHttpRequest from JavaScript, you should provide these headers :
      # "X-CSRF-Token" => extract_csrf_token(response.body),
      # "X-Requested-With" => "XMLHttpRequest"
    }
  end

  CSRF_REGEX = /<meta name="csrf-token" content="([^"]+)"/

  def extract_csrf_token(html)
    html.match(CSRF_REGEX)[1]
  end
end

# Simulates 100 concurrent visitors every second for 10 minutes
RegistrationTsunami.start(concurrency: 100, duration: 10)
```

This is more complex because it handles CSRF and every submitted forms are unique.
Indeed emails must be unique, so it's not possible to send the same data everytime.

## Output and result

Web Tsunami does not measure response time or print any result.
If you are running a load test, that means you should use an APM (application performance monitoring).
It already collects and displays all data you need such as throughput, response time and bottlenecks.

So, the only output are errors.

## License

The gem is available as open-source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

Rails developer? Check out [RoRvsWild](https://rorvswild.com), our Ruby on Rails application monitoring tool.

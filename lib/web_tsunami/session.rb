# frozen_string_literal: true

module WebTsunami
  # Session is a helper class to be used inside a scenario.
  # It's purpose is to avoid low level manipulations to handle cookies and CSRF tokens automatically.
  class Session
    attr_reader :scenario, :root_url

    attr_reader :cookies, :last_response

    def initialize(scenario, root_url)
      @scenario = scenario
      @root_url = root_url
      @cookies = {}
      @last_response = nil
    end

    def get(path, options = {}, &block)
      url = File.join(root_url, path)
      inject_headers(default_headers, options)
      scenario.get(url, options) do |response|
        @last_response = response
        save_cookies(response)
        block&.call(response)
      end
    end

    def post(path, options = {}, &block)
      url = File.join(root_url, path)
      inject_headers(default_post_headers, options)
      inject_csrf_token(options)
      scenario.post(url, options) do |response|
        @last_response = response
        save_cookies(response)
        block&.call(response)
      end
    end

    private

    def default_headers
      {
        "Origin" => last_response && request_origin_header(last_response.request),
        "Cookie" => cookies.map { |(k,v)| "#{k}=#{v}" }.join(" "),
      }
    end

    def default_post_headers
      default_headers.merge("Content-Type" => "application/x-www-form-urlencoded;charset=UTF-8")
    end

    def request_origin_header(request)
      return "null" unless request
      uri = URI(request.base_url.to_s)
      if [80, 443].include?(uri.port)
        "#{uri.scheme}://#{uri.host}"
      else
        "#{uri.scheme}://#{uri.host}:#{uri.port}"
      end
    end

    CSRF_REGEX = /<meta name="csrf-token" content="([^"]+)"/

    def extract_csrf_token(html)
      html.match(CSRF_REGEX)[1]
    end

    def save_cookies(response)
      return unless header = response.headers["Set-Cookie"]
      Array(header).each do |cookie|
        name, value = cookie.split(" ", 2)[0].split("=")
        @cookies[name] = value
      end
    end

    def inject_headers(headers, options)
      options[:headers] = headers.merge(options[:headers] || {})
    end

    def inject_csrf_token(options)
      if options[:body].is_a?(Hash) && last_response
        options[:body] = {authenticity_token: extract_csrf_token(last_response.body)}.merge(options[:body])
      end
    end
  end
end

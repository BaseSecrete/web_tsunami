# -*- encoding : utf-8 -*-

require 'typhoeus'

module WebTsunami
  class Scenario

    attr_reader :concurrency

    def self.start(options)
      options[:duration].times { fork { new(options[:concurrency]).start } and sleep(1) }
      Process.wait
    end

    def initialize(concurrency)
      @concurrency = concurrency
    end

    def requests
      @requests ||= Typhoeus::Hydra.new
    end

    def get(url, options = {}, &block)
      request(:get, url, options, &block)
    end

    def post(url, options = {}, &block)
      request(:post, url, options, &block)
    end

    def put(url, options = {}, &block)
      request(:put, url, options, &block)
    end

    def patch(url, options = {}, &block)
      request(:patch, url, options, &block)
    end

    def delete(url, options = {}, &block)
      request(:delete, url, options, &block)
    end

    def request(method, url, options, &block)
      req = Typhoeus::Request.new(url, {method: method}.merge(options))
      requests.queue(req)
      req.on_complete do |response|
        if response.timed_out?
          puts "Timeout #{url}"
        elsif response.code == 0
          puts "#{response.return_message} #{url}"
        elsif !response.success? && response.code != 302
          puts "#{response.code} #{url}"
        end
        block.call(response) if block
      end
    end

    def start
      concurrency.times { run }
      requests.run
    end

    def run
      raise NotImplementedError
    end

  end
end

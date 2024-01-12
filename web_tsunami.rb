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
      @sleeps = {}
      @concurrency = concurrency
    end

    def requests
      @requests ||= Typhoeus::Hydra.new
    end

    def get(url, &block)
      requests.queue(req = Typhoeus::Request.new(url, request_options))
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

    def request_options
      {}
    end

  end
end

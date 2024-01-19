# -*- encoding: utf-8 -*-

require_relative "lib/web_tsunami/version"

Gem::Specification.new do |s|
  s.name          = "web_tsunami"
  s.version       = WebTsunami::VERSION
  s.authors       = ["Alexis Bernard"]
  s.email         = ["alexis@basesecrete.com"]
  s.homepage      = "https://github.com/BaseSecrete/web_tsunami"
  s.summary       = "Tailor-made load testing for web apps"
  s.description   = "Write realistic scenarios to test the load of a web application."
  s.license       = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.metadata["source_code_uri"] = "https://github.com/BaseSecrete/web_tsunami"
  s.metadata["changelog_uri"] = "https://github.com/BaseSecrete/web_tsunami/blob/master/CHANGELOG.md"

  s.add_runtime_dependency "typhoeus"
end

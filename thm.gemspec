# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
VERSION = "0.1.5"

Gem::Specification.new do |spec|
  spec.name          = "thm"
  spec.version       = VERSION
  spec.authors       = ["puppetpies"]
  spec.email         = "brianh6854@googlemail.com"
  spec.description   = "Threatmonitor - Packet Capture / Analysis Suite"
  spec.summary       = "Packet Data Analysis"
  spec.homepage      = "https://github.com/puppetpies/threatmonitor"
  spec.requirements  = "libpcap"
  spec.license       = "MIT"

  spec.files = [
    "datalayerlight.rb",
    "thm-authentication.rb",
    "thm-authorization.rb",
    "thm-consumer.rb",
    "thm-producer.rb",
    "thm-privileges.rb",
    "thm-session.rb",
    "thm-useradmin.rb",
    "thm-pcap.rb",
    "service_definitions.csv"
    "lib/thm.rb",
    "lib/thm/consumer.rb",
    "lib/thm/dataservices.rb",
    "lib/thm/localmachine.rb",
    "lib/thm/producer.rb",
    "lib/thm/version.rb",
    "js/jquery.min.js",
    "js/chartkick.js",
    "js/JSXTransformer.js",
    "js/marked.min.js",
    "js/react.js",
    "stylesheets/screen.css",
    "sql/geoipdata-monetdb.sql",
    "sql/threatmonitor-monetdb.sql",
    "sql/threatmonitor-mysql.sql",
    "views/authenticate.slim",
    "views/dashboard.erb",
    "views/logout.slim"
  ]

  spec.extra_rdoc_files = [
    "README.md",
    "README.1ST"
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rake-compiler", "~> 0.9"
  spec.add_runtime_dependency "bunny", "~> 1.7"
  spec.add_runtime_dependency "amqp", "~> 1.5"
  spec.add_runtime_dependency "pcap", "~> 0.7"
  spec.add_runtime_dependency "guid", "~> 0.1"
  spec.add_runtime_dependency "eventmachine", "~> 1.0"
  spec.add_runtime_dependency "chartkick", "~> 1.3"
  spec.add_runtime_dependency "sinatra", "~> 1.4"
  spec.add_runtime_dependency "slim", "~> 3.0"
end

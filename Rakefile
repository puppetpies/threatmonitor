# coding: utf-8
require './lib/thm/version.rb'

def java?
  /java/ === RUBY_PLATFORM
end

ENV['LANG'] = "en_US.UTF-8"

VERSION = Thm::VERSION::STRING

Gem::Specification.new do |spec|
  spec.name          = "thm"
  spec.version       = VERSION
  spec.authors       = ["puppetpies"]
  spec.email         = "brianh6854@googlemail.com"
  spec.description   = "Threatmonitor - Packet Capture / Analysis Suite"
  spec.summary       = "Packet Data Analysis"
  spec.executables = ["thm-consumer", "thm-producer", "thm-session", "thm-useradmin", "thm-pcap", "thm-trafviz"]
  spec.homepage      = "https://github.com/puppetpies/threatmonitor"
  spec.requirements  = "libpcap"
  spec.license       = "MIT"

  spec.files = [
    "config.rb",
    "Rakefile",
    "lib/thm/datalayerlight.rb",
    "thm-authentication.rb",
    "thm-authorization.rb",
    "bin/thm-consumer",
    "bin/thm-producer",
    "bin/thm-session",
    "bin/thm-useradmin",
    "bin/thm-pcap",
    "bin/thm-trafviz",
    "thm-privileges.rb",
    "service_definitions.csv",
    "lib/thm.rb",
    "lib/monkeypatches.rb",
    "lib/thm/consumer.rb",
    "lib/thm/dataservices.rb",
    "lib/thm/fileservices.rb",
    "lib/thm/localmachine.rb",
    "lib/thm/producer.rb",
    "lib/thm/version.rb",
    "lib/thm/dataservices/geolocation/geolocation.rb",
    "lib/thm/dataservices/trafviz/trafviz.rb",
    "lib/thm/dataservices/external.rb",
    "lib/thm/dataservices/safebrowsing_api.rb",
    "js/jquery.min.js",
    "js/chartkick.js",
    "js/JSXTransformer.js",
    "js/marked.min.js",
    "js/react.js",
    "js/jsapi.js",
    "js/files/authenticate.jsx",
    "stylesheets/screen.css",
    "sql/geoipdata-monetdb.sql",
    "sql/threatmonitor-monetdb.sql",
    "sql/threatmonitor-mysql.sql",
    "sql/threatmonitor-http.sql",
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
  spec.add_runtime_dependency "keycounter", "~> 0.0.8"
  spec.add_runtime_dependency "walltime", "~> 0.0.5"
end

require 'rubygems/tasks'
Gem::Tasks.new
task :default do

end

# Override standard release task
require 'git'
Rake::Task["release"].clear
task :release do
  version = "#{VERSION}"
  remote = 'origin'
  puts "Creating tag v#{version}"
  git = Git.open(".")
  git.add_tag("v#{version}")
  puts "Pushing tag to #{remote}"
  git.push(remote, 'master', true)
  Rake::Task['gem'].invoke
  gemtask = Gem::Tasks::Push.new
  gemtask.push("pkg/thm-#{version}.gem")
end

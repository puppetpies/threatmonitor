########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Producer
#
# Producer / Consumer controller module
#
########################################################################

require 'rubygems'
require 'amqp'
require 'bunny'
require 'eventmachine'
require 'guid'
require 'yaml'
require 'pcaplet'
require 'pcaprub' # For Live capture / write
include Pcap

# TODO
#
# Create def's for that packet SQL / Refactor to provent code duplication
# Create def's for Hash table YAML same idea as above.
    
module Tools

  class << self
  
    def guid
      guid = Guid.new # Generate GUID
    end

    def log_errors(file, data)
      File.open("#{file}", 'a') {|n|
        n.puts("#{data}")
      }
    end
  
  end
  
end

# Load Database drivers
require File.expand_path(File.join(
          File.dirname(__FILE__),
          "../lib/thm/datalayerlight.rb"))
          
# Load Datasources / Services contains defaults
require File.expand_path(File.join(
          File.dirname(__FILE__),
          "../lib/thm/dataservices.rb"))

require File.expand_path(File.join(
          File.dirname(__FILE__), 
	  "../lib/thm/producer.rb"))

require File.expand_path(File.join(
          File.dirname(__FILE__),
	  "../lib/thm/consumer.rb"))

require File.expand_path(File.join(
          File.dirname(__FILE__), 
	  "../lib/thm/localmachine.rb"))

require File.expand_path(File.join(
          File.dirname(__FILE__), 
	  "../lib/thm/fileservices.rb"))

# Versioning information
require File.expand_path(File.join(
          File.dirname(__FILE__),
	  "../lib/thm/version.rb"))

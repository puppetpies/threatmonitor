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
require './datalayerlight.rb'
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
  
  end
  
end

# Load Datasources
require "#{File.dirname(__FILE__)}/thm/dataservices.rb"
require "#{File.dirname(__FILE__)}/thm/producer.rb"
require "#{File.dirname(__FILE__)}/thm/consumer.rb"
require "#{File.dirname(__FILE__)}/thm/localmachine.rb"
require "#{File.dirname(__FILE__)}/thm/version.rb"



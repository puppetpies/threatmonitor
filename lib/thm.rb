########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
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
require 'user_agent_parser'
include Pcap

class String

  def size_minus(min=1)
    size - min
  end

end

module Tools

  class << self
    
    # Guid.new isn't hard but this Module will expand
    def guid
      guid = Guid.new # Generate GUID
    end
    
    # User agent parsing magic for Trafviz via uap-ruby on Github
    def ua_parser(agent)
      # Load all user agent data / regexp / patterns once
      @ua ||= UserAgentParser::Parser.new
      @ua.parse(agent)
    end
    
    # Thm system errors
    def log_errors(file, data)
      File.open("#{file}", 'a') {|n|
        n.puts("#{data}")
      }
    end
    
  end

  # User defined functions
  def use_const_defined_unless?(const)
    const_down = const.downcase
    if Kernel.const_defined?("#{const}")
      if instance_variable_get("@#{const_down}") == nil
        instance_variable_set("@#{const_down}", Kernel.const_get("#{const}"))
        puts "Config Constant #{const}: #{Kernel.const_get("#{const}")}"
        puts "Instance Variable @#{const_down}: #{instance_variable_get("@#{const_down}")}"
      else
        puts "Param via Getoptlong: Instance Variable #{@const_down}: #{instance_variable_get("@#{const_down}")}"
      end
    else
      raise "No Config option set add #{const} to your config.rb"
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

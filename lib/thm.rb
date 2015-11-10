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


# Slight patch here
# Needs to moving to monkeypatches.rb

class MonetDBConnection

  # perform a real connection; retrieve challenge, proxy through merovinginan, build challenge and set the timezone
  def real_connect
    
    server_challenge = retrieve_server_challenge()
    if server_challenge != nil
      salt = server_challenge.split(':')[0]
      @server_name = server_challenge.split(':')[1]
      @protocol = server_challenge.split(':')[2].to_i
      @supported_auth_types = server_challenge.split(':')[3].split(',')
      @server_endianness = server_challenge.split(':')[4]
=begin 
Causes issues with Threatmonitor
      #if @@SUPPORTED_PROTOCOLS.include?(@protocol) == False
      #  raise MonetDBProtocolError, "Protocol not supported. The current implementation of ruby-monetdb works with MAPI protocols #{@@SUPPORTED_PROTOCOLS} only."
      #end
=end
      @pwhash = server_challenge.split(':')[5]
    else
      raise MonetDBConnectionError, "Error: server returned an empty challenge string."
    end
    
    # The server supports only RIPMED160 or crypt as an authentication hash function, but the driver does not.
    if @supported_auth_types.length == 1
      auth = @supported_auth_types[0]
      if auth.upcase == "RIPEMD160"
        raise MonetDBConnectionError, auth.upcase + " " + ": algorithm not supported by ruby-monetdb."
      end
    end

    reply = build_auth_string_v9(@auth_type, salt, @database)

    if @socket != nil
      @connection_established = true

      send(reply)
      monetdb_auth = receive
      
      if monetdb_auth.length == 0
        # auth succedeed
        true
      else
        if monetdb_auth[0].chr == MSG_REDIRECT
        #redirection
          
          redirects = [] # store a list of possible redirects
          
          monetdb_auth.split('\n').each do |m|
            # strip the trailing ^mapi:
            # if the redirect string start with something != "^mapi:" or is empty, the redirect is invalid and shall not be included.
            if m[0..5] == "^mapi:"
              redir = m[6..m.length]
              # url parse redir
              redirects.push(redir)  
            else
              $stderr.print "Warning: Invalid Redirect #{m}"
            end          
          end
          
          if redirects.size == 0  
            raise MonetDBConnectionError, "No valid redirect received"
          else
            begin 
              uri = URI.split(redirects[0])
              # Splits the string on following parts and returns array with result:
              #
              #  * Scheme
              #  * Userinfo
              #  * Host
              #  * Port
              #  * Registry
              #  * Path
              #  * Opaque
              #  * Query
              #  * Fragment
              server_name = uri[0]
              host   = uri[2]
              port   = uri[3]
              database   = uri[5].gsub(/^\//, '') if uri[5] != nil
            rescue URI::InvalidURIError
              raise MonetDBConnectionError, "Invalid redirect: #{redirects[0]}"
            end
          end
          
          if server_name == MONETDB_MEROVINGIAN
            if @auth_iteration <= MEROVINGIAN_MAX_ITERATIONS
              @auth_iteration += 1
              real_connect
            else
              raise MonetDBConnectionError, "Merovingian: too many iterations while proxying."
            end
          elsif server_name == MONETDB_MSERVER
            begin
              @socket.close
            rescue
              raise MonetDBConnectionError, "I/O error while closing connection to #{@socket}"
            end
            # reinitialize a connection
            @host = host
	          @port = port
            
            connect(database, @auth_type)
          else
            @connection_established = false
            raise MonetDBConnectionError, monetdb_auth
          end
        elsif monetdb_auth[0].chr == MSG_INFO
          raise MonetDBConnectionError, monetdb_auth
        end
      end
    end
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
      unless instance_variable_defined?("@#{const_down}")
        instance_variable_set("@#{const_down}", Kernel.const_get("#{const}"))
        puts "Config Constant #{const}: #{Kernel.const_get("#{const}")}"
        puts "Instance Variable @#{const_down}: #{instance_variable_get("@#{const_down}")}"
      else
        puts "Param via Getoptlong: Instance Variable @#{const_down}: #{instance_variable_get("@#{const_down}")}"
      end
    else
      raise "No Config option set add #{const} to your config.rb"
    end
  end
  
end

module TextProcessing


    def text_highlighter(text)
      keys = ["Linux", "Java", "Android", "iPhone", "Mobile", "Chrome", 
               "Safari", "Mozilla", "Gecko", "AppleWebKit", "Windows", 
               "MSIE", "Win64", "Trident", "wispr", "PHPSESSID", "JSESSIONID",
               "AMD64", "Darwin", "Macintosh", "Mac OS X", "Dalvik", "text/html", "xml"]
      cpicker = [2,3,4,1,7,5,6] # Just a selection of colours
      keys.each {|n|
        text.gsub!("#{n}", "\e[4;3#{cpicker[rand(cpicker.size)]}m#{n}\e[0m\ \e[0;32m".strip)
      }
      return text
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

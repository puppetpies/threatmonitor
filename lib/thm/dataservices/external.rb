########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries - External
#
#   For external REST / API Services
#
########################################################################

require 'net/http'
require 'uri'
require 'json'

module Thm

  class DataServices::External

    attr_writer :debug
    
    def initialize
      @debug = false
    end
    
    def apiget(url)
      uri = URI.parse("#{url}")
      puts "Request URI: #{url}" unless @debug == false
      http = Net::HTTP.new(uri.host, uri.port)
      if url =~ %r=^https:=
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      begin
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        puts response.body unless @debug == false
        return response
      rescue
        raise Exception, "Error retrieving data"
      end
    end
    
    def apipost(url, body="")
      uri = URI.parse("#{url}")
      puts "Request URI: #{url}" unless @debug == false
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_content_type("application/json")
      begin
        request.body = body unless body.empty?
        response = http.request(request)
      rescue
        raise Exception, "Error posting data"
      end
    end
    
    def apidelete(url)
      uri = URI.parse("#{url}")
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        response = http.request(Net::HTTP::Delete.new(uri.request_uri))
      rescue
        raise Exception, "Error posting data"
      end
    end

  end

end

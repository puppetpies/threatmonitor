########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries - External
#
#   For Google Safebrowsing API
#
########################################################################

module Thm
  
  class DataServices::Safebrowsing < DataServices::External
    
    attr_writer :debug

    def initialize
      super
    end
    
    def handle_response?(code)
      if code == "200"
        return code
      elsif code == "204"
        return code
      elsif code == "400"
        puts "Bad Request—The HTTP request was not correctly formed. The client did not provide all required CGI parameters."
        return false
      elsif code == "401"
        puts "Not Authorized—The client id is invalid."
        return false      
      elsif code == "503"
        puts "Service Unavailable"
        return false
      elsif code == "505"
        puts "HTTP Version Not Supported—The server CANNOT handle the requested protocol major version."
        return false
      end    
    end
  
    def lookup(url)
      response = apiget(url)
      print "Response: "
      pp response
      if handle_response?(response.code) =~ %r=^200|^204=
        return [response.code, response.body]
      else
        return false
      end
    end

  end

end
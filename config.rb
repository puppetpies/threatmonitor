########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Threatmonitor User configuration
#
# Lets keep it simple and use constants
########################################################################

module Thm

  module Defaults
  
    DATASTORE = "monetdb"
    MQHOST = "127.0.0.1"
    MQUSER = "traffic"
    MQPASS = "dk3rbi9l"
    MQVHOST = "/"
    DBHOST = "127.0.0.1"
    DBUSER = "threatmonitor"
    DBPASS = "dk3rbi9l"
    DBNAME = "threatmonitor"
    QUEUEPREFIX = "wifi"
    TBLNAME_IPPACKET = "#{QUEUEPREFIX}_ippacket"
    TBLNAME_TCPPACKET = "#{QUEUEPREFIX}_tcppacket"
    TBLNAME_UDPPACKET = "#{QUEUEPREFIX}_udppacket"

    # Regexp strings first currently excludes POST Data
    HTTP_METHODS_REGEXP = %r=^GET |^HEAD |^PUT |^TRACE |^CONNECT |^OPTIONS |^DELETE |^PROPFIND |^PROPPATCH |^MKCOL |^COPY |^MOVE |^LOCK |^UNLOCK =
    HTTP_METHODS_REGEXP_RESPONSE = %r=^(HTTP\/.*)$=
    HTTP_REQUEST_TABLE = "http_traffic_json"
    HTTP_RESPONSE_TABLE = "http_traffic_json"
    HTTP_REQUEST_TABLE_UA = "http_traffic_ua"
    
    # Misc
    SNAPLENGTH = 65536
    INTERFACE = "eth0"
    
    # Google Safe Browsing API
    SAFEBROWSING_ENABLED = false
    SAFEBROWSING_API_KEY = "12345"
    GOOGLE_API_PROJECTNAME = "myproject"
    SAFEBROWSING_URL = "https://sb-ssl.google.com/safebrowsing/api/lookup?client=#{GOOGLE_API_PROJECTNAME}&key=#{SAFEBROWSING_API_KEY}&appver=1.5.2&pver=3.1&url="

    GEOCODING_ENABLED = false
    GEOCODING_API_KEY = "12345"
    GEOCODING_URL = "https://maps.googleapis.com/maps/api/geocode/json?key=#{GEOCODING_API_KEY}&" # Format: "latlng=40.714224,-73.961452"
    
  end

end

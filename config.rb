########################################################################
#
# Author: Brian Hood
#
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
    HTTP_REQUEST_TABLE = "http_request"
    HTTP_RESPONSE_TABLE = "http_response"
    
    # Misc
    SNAPLENGTH = 65536
    INTERFACE = "eth0"

  end

end

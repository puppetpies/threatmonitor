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
          
  end

end

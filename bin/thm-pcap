
########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Pcap
#
# Producer - Save data from Pcap file(s) to Database
#
########################################################################

require 'getoptlong'
require "#{File.dirname(__FILE__)}/lib/thm.rb"
require "#{File.dirname(__FILE__)}/config.rb"

include Thm::Defaults

ARGV[0] = "--help" if ARGV[0] == nil

banner = "\e[1;34mWelcome to Threatmonitor PCap Loader \e[0m\ \n"
banner << "\e[1;34m===================================\e[0m\ \n"

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--pcapfile', '-f', GetoptLong::OPTIONAL_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      helper = %q[
-h, --help:
   show help
   
-f, --pcapfile [ REQUIRED ] 
]
      puts banner
      puts helper
      exit
    when '--pcapfile'
      @pcapfile = arg
  end
end

puts banner
# See thmmq.rb for list for variables
obj = Thm::Localmachine.new
obj.datastore = DATASTORE
obj.mqhost = MQHOST
obj.mquser = MQUSER
obj.mqpass = MQPASS
obj.mqvhost = MQVHOST
obj.dbhost = DBHOST
obj.dbuser = DBUSER
obj.dbpass = DBPASS
obj.dbname = DBNAME
obj.queueprefix = QUEUEPREFIX
obj.tblname_ippacket = TBLNAME_IPPACKET
obj.tblname_tcppacket = TBLNAME_TCPPACKET
obj.tblname_udppacket = TBLNAME_UDPPACKET
obj.dbconnect
# Send data to database from queue
if @pcapfile.nil? == false
  obj.from_pcap_db("#{@pcapfile}")
end


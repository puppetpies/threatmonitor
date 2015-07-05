
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
require "#{File.dirname(__FILE__)}/lib/thmmq.rb"

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
obj.datastore = "mysql"
obj.dbhost = "172.17.0.1"
obj.dbuser = "threatmonitor"
obj.dbpass = "dk3rbi9L"
obj.dbname = "threatmonitor"
obj.tblname_ippacket = "wifi_ippacket"
obj.tblname_tcppacket = "wifi_tcppacket"
obj.tblname_udppacket = "wifi_udppacket"
obj.dbconnect
# Send data to database from queue
if @pcapfile.nil? == false
  obj.from_pcap_db("#{@pcapfile}")
end


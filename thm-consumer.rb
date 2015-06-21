########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Consumer
#
# Producer - Save data from queue to Database
#
################################################### #####################

require 'getoptlong'
require './thmmq.rb'

ARGV[0] = "--help" if ARGV[0] == nil

banner = "\e[1;34mWelcome to Threatmonitor Consumer \e[0m\ \n"
banner << "\e[1;34m=================================\e[0m\ \n"

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--infinite', '-i', GetoptLong::NO_ARGUMENT ],
  [ '--passes', '-p', GetoptLong::REQUIRED_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      helper = %q[
-h, --help:
   show help
   
-i, --infinite [ For consuming live captures ]
  
-p, --passes number of passes  [ For medium / larger queues ]

NOTES:

  Press CTRL+C to exit Reactor thread at anytime to move on to next queue.
  There are currently 3 queues ippacket, tcppacket, udppacket
  
    ]
      puts banner
      puts helper
      exit
    when '--infinite'
      @infinite = arg
    when '--passes'
      @passes = arg
  end
end

puts banner
# See thmmq.rb for list for variables
obj = Thm::Consumer.new
obj.queueprefix = "wifi"
obj.tblname_ippacket = "wifi_ippacket"
obj.tblname_tcppacket = "wifi_tcppacket"
obj.tblname_udppacket = "wifi_udppacket"
obj.mqconnect
obj.dbconnect
# Send data to database from queue
if @infinite.nil? == false
  obj.infinite
elsif @passes.nil? == false
  obj.passes(@passes.to_i)
else
  obj.from_mq_to_db
end
obj.mqclose


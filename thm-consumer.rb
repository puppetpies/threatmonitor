########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Consumer
#
# Producer - Save data from queue to Database
#
########################################################################

require 'getoptlong'
require "#{File.dirname(__FILE__)}/lib/thm.rb"
require "#{File.dirname(__FILE__)}/config.rb"

include Thm::Defaults

ARGV[0] = "--help" if ARGV[0] == nil

banner = "\e[1;34mWelcome to Threatmonitor Consumer \e[0m\ \n"
banner << "\e[1;34m=================================\e[0m\ \n"

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--infinite', '-i', GetoptLong::NO_ARGUMENT ],
  [ '--passes', '-p', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--runonce', '-r', GetoptLong::NO_ARGUMENT ]
)

opts.each do |opt, arg|
  case opt
    when '--help'
      helper = %q[
-h, --help:
   show help
   
-i, --infinite [ For consuming live captures ]
  
-p, --passes number of passes  [ For medium / larger queues ]

-r, --runonce [ Just as it says ]

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
    when '--runonce'
      @runonce = arg
  end
end

puts banner
# See thmmq.rb for list for variables
obj = Thm::Consumer.new
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
obj.mqconnect
obj.dbconnect
# Send data to database from queue
if @infinite.nil? == false
  obj.infinite
elsif @passes.nil? == false
  obj.passes(@passes.to_i)
elsif @runonce.nil? == false
  obj.from_mq_to_db
end
obj.mqclose


########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Producer
#
# Producer - Load data Database to RabbitMQ for distrubition or Packet 
#            Trace live data and send to RabbitMQ
########################################################################

require 'getoptlong'
require "#{File.dirname(__FILE__)}/lib/thm.rb"

ARGV[0] = "--help" if ARGV[0] == nil

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--mode', '-m', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--queueprefix', '-q', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--interface', '-i', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--filter', '-f', GetoptLong::REQUIRED_ARGUMENT ]
)

banner = "\e[1;34mWelcome to Threatmonitor Producer \e[0m\ \n"
banner << "\e[1;34m=================================\e[0m\ \n"

opts.each do |opt, arg|
  case opt
    when '--help'
      helper = %q[
-h, --help:
   show help
   
-m, --mode database / capture [ REQUIRED ]
  
-q, --queueprefix queue name [ REQUIRED ]

-i --interface network interface [ REQUIRED ]
 
-f --filter your pcap / tcpdump style filter [ OPTIONAL ]
    ]
      puts banner
      puts helper
      exit
    when '--mode'
      @modeparam = arg
    when '--queueprefix'
      @queueprefix = arg
    when '--interface'
      @interface = arg
    when '--filter'
      @filter = arg
  end
end

puts banner
# See thmmq.rb for list for variables
obj = Thm::Producer.new
obj.datastore = "monetdb"
#obj.dbhost = "172.17.0.1"
#obj.dbuser = "threatmonitor"
#obj.dbpass = "dk3rbi9L"
#obj.dbname = "threatmonitor"
obj.queueprefix = @queueprefix
obj.mqconnect
obj.dbconnect unless @modeparam == "capture"
mode = @modeparam

if mode == "database"
  # Send data from Database to RabbitMQ for Fanout etc
  ippacketsql = "SELECT * FROM \"threatmonitor\".#{obj.tblname_ippacket} LIMIT 300 OFFSET 400000"
  obj.from_db_to_mq(ippacketsql)

elsif mode == "capture"
  # From Pcap to RabbitMQ for Fanout etc.
  # 
  # Standard Pcap / Wireshark filters 
  # 'tcp port not 22 and not arp and udp port not 53 and udp portrange not 67-69 and tcp port not 8443 and host not 78.47.223.130'
  if %x{id -u}.strip != "0"
    puts "Require superuser privileges"
    exit
  end
  obj.from_interface_to_mq("#{@interface}", "#{@filter}")
  #obj.from_pcap_to_mq("wlo1", "tcp port not 22")
  obj.mqclose
end

########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Consumer
#
# Producer - Save data from queue to Database
#
################################################### #####################

require './thmmq.rb'

banner = "\e[1;34mWelcome to Threatmonitor Consumer \e[0m\ \n"
banner << "\e[1;34m=================================\e[0m\ \n"
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
obj.from_mq_to_db

obj.mqclose


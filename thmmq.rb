########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Producer
#
# Producer / Consumer controller module
#
########################################################################

require 'rubygems'
require 'amqp'
require 'bunny'
require 'eventmachine'
require 'guid'
require 'yaml'
require 'pcaplet'
require 'pcaprub' # For Live capture / write
require './datalayerlight.rb'
include Pcap

# TODO
#
# Create def's for that packet SQL / Refactor to provent code duplication
# Create def's for Hash table YAML same idea as above.

trap("INT") {
  
  if EM.reactor_running? == true
    puts "Exiting Reactor thread ..."
    EventMachine.stop
  end
  exit
}
          
module Tools

  class << self
  
    def guid
      guid = Guid.new # Generate GUID
    end
  
  end
  
end

module Thm

  class DataServices

    #  Example variables
    #
    #  obj = Thm::Producer.new
    #  obj.mqhost = "127.0.0.1"
    #  obj.mquser = "test"
    #  obj.mqpass = "setone"
    #  obj.mqconnect
    #  obj.dbconnect
    
    attr_accessor :datastore, :mqhost, :mquser, :mqpass, :mqvhost, :dbhost, :dbuser, :dbpass, :dbname, :queueprefix, :tblname_ippacket, :tblname_tcppacket, :tblname_udppacket
    
    def initialize
      @datastore = "monetdb"
      @mqhost = "127.0.0.1"
      @mquser = "traffic"
      @mqpass = "dk3rbi9l"
      @mqvhost = "/"
      @dbhost = "127.0.0.1"
      @dbuser = "threatmonitor"
      @dbpass = "dk3rbi9l"
      @dbname = "threatmonitor"
      @queueprefix = "cactus" # Queue names will be come prefixed with cactus_ippacket etc ..
      # Implement tblname for table freedom
      @tblname_ippacket = "ippacket"
      @tblname_tcppacket = "tcppacket"
      @tblname_udppacket = "udppacket"
      @mqconn = Bunny.new(:hostname => "#{@mqhost}", :user => "#{@mquser}", :pass => "#{@mqpass}", :vhost => "#{@mqvhost}")
    end
    
    def mqconnect
      @mqconn.start
      @ch = @mqconn.create_channel
    end
    
    def mqclose
      @conn.close
    end
    
    def dbconnect
      if @datastore == "mysql"
        @conn = DatalayerLight::MySQLDrv.new
        puts "Using MySQL Datasource"
      elsif @datastore == "monetdb"
        @conn = DatalayerLight::MonetDBDrv.new
        puts "Using MonetDB Datasource"
      end
      @conn.hostname = @dbhost
      @conn.username = @dbuser
      @conn.password = @dbpass
      @conn.dbname = @dbname
      @conn.autocommit = false
      begin
        @conn.connect
      rescue Errno::ECONNREFUSED
        puts "Database not running!"
        puts "Bye!"
        exit
      end
    end

  end
  
  class Producer < DataServices
    
    def from_pcap_to_mq(interface, pcapfilters="")
      # TODO
      trace = Pcaplet.new("-n -i #{interface}")
      if pcapfilters != ""
        filter1 = Pcap::Filter.new("#{pcapfilters}", trace.capture)
        trace.add_filter(filter1)
        puts "Using Filter: #{pcapfilters}"
      end
      puts "Packet capture in progress press CTRL+C to exit ..."
      trace.each_packet { |pkt|
        guid = Tools::guid # IP / TCP / UDP relationship
        if pkt.ip?
          pcktdata = {  'ippacket' => { 
                  'guid' => "#{guid}", 
                  'recv_date' => Time.now, 
                  'ip_df' => pkt.ip_df?, 
                  'ip_dst' => "#{pkt.ip_dst}",
                  'ip_hlen' => pkt.ip_hlen,
                  'ip_id' => pkt.ip_id,
                  'ip_len' => pkt.ip_len,
                  'ip_mf' => pkt.ip_mf?,
                  'ip_off' => pkt.ip_off,
                  'ip_proto' => pkt.ip_proto,
                  'ip_src' => "#{pkt.ip_src}",
                  'ip_sum' => pkt.ip_sum,
                  'ip_tos' => pkt.ip_tos,
                  'ip_ttl' => pkt.ip_ttl,
                  'ip_ver' => pkt.ip_ver
                } 
          }
          pcktyaml = pcktdata.to_yaml
          q = @ch.queue("#{@queueprefix}_ippacket")
          @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)
        end
        
        if pkt.tcp?
          pcktdata = { 'tcppacket' => {
                  'guid' => "#{guid}",
                  'recv_date' => Time.now,
                  'tcp_data_len' => pkt.tcp_data_len,
                  'tcp_dport' => pkt.tcp_dport,
                  'tcp_ack' => pkt.tcp_ack?,
                  'tcp_fin' => pkt.tcp_fin?,
                  'tcp_syn' => pkt.tcp_syn?,
                  'tcp_rst' => pkt.tcp_rst?,
                  'tcp_psh' => pkt.tcp_psh?,
                  'tcp_urg' => pkt.tcp_urg?,
                  'tcp_off' => pkt.tcp_off,
                  'tcp_hlen' => pkt.tcp_hlen,
                  'tcp_seq' => pkt.tcp_seq,
                  'tcp_sum' => pkt.tcp_sum,
                  'tcp_sport' => pkt.tcp_sport,
                  'tcp_urp' => pkt.tcp_urp,
                  'tcp_win' => pkt.tcp_win
                }
            }
            pcktyaml = pcktdata.to_yaml
            q = @ch.queue("#{@queueprefix}_tcppacket")
            @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)
        end
        
        if pkt.udp?
            pcktdata = { 'udppacket' => {
                  'guid' => "#{guid}",
                  'recv_date' => Time.now,
                  'udp_dport' => pkt.udp_dport,
                  'udp_len' => pkt.udp_len,
                  'udp_sum' => pkt.udp_sum,
                  'udp_sport' => pkt.udp_sport
                }
            }
            pcktyaml = pcktdata.to_yaml
            q = @ch.queue("#{@queueprefix}_udppacket")
            @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)       
        end
      }
    end
        
    def from_db_to_mq(ippacketsql)
      # Retrieve GUID
      n, t, s, v = 1, 1, 1, 1
      if @conn.is_connected?
        res = @conn.query("#{ippacketsql}")
        while row = res.fetch_hash do
          guid = row["guid"].strip
          if t == 100
            puts "MSGID: #{n} GUID: #{guid}"
            t = 0
          end
          t = t + 1 unless t == 100
          pcktdata = {  'ippacket' => { 
                  'guid' => row["guid"], 
                  'recv_date' => row["recv_date"], 
                  'ip_df' => row["ip_df"], 
                  'ip_dst' => row["ip_dst"],
                  'ip_hlen' => row["ip_hlen"],
                  'ip_id' => row["ip_id"],
                  'ip_len' => row["ip_len"],
                  'ip_mf' => row["ip_mf"],
                  'ip_off' => row["ip_off"],
                  'ip_proto' => row["ip_proto"],
                  'ip_src' => row["ip_src"],
                  'ip_sum' => row["ip_sum"],
                  'ip_tos' => row["ip_tos"],
                  'ip_ttl' => row["ip_ttl"],
                  'ip_ver' => row["ip_ver"]
                } 
          }
          pcktyaml = pcktdata.to_yaml
          q = @ch.queue("#{@queueprefix}_ippacket")
          @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)
          # TCP Packet
          #puts "Process TCP Data"
          tcppacketsqlcount = "SELECT COUNT(*) as num FROM #{@tblname_tcppacket} WHERE guid = '#{guid}'"
          res2count = @conn.query("#{tcppacketsqlcount}")
          row2count = res2count.fetch_hash
          tcpcount = row2count["num"]
          #puts "TCP Record Count: #{tcpcount}" if tcpcount.to_i > 0
          tcppacketsql = "SELECT * FROM #{@tblname_tcppacket} WHERE guid = '#{guid}'"
          res2 = @conn.query("#{tcppacketsql}")
          while row2 = res2.fetch_hash do
            if s == 100
              puts "TCP: MSGID: #{n} GUID: #{guid}"
              s = 0
            end
            s = s + 1 unless s == 100
            pcktdata = { 'tcppacket' => {
                    'guid' => row2["guid"],
                    'recv_date' => row2["recv_date"],
                    'tcp_data_len' => row2["tcp_data_len"],
                    'tcp_dport' => row2["tcp_dport"],
                    'tcp_ack' => row2["tcp_ack"],
                    'tcp_fin' => row2["tcp_fin"],
                    'tcp_syn' => row2["tcp_syn"],
                    'tcp_rst' => row2["tcp_rst"],
                    'tcp_psh' => row2["tcp_psh"],
                    'tcp_urg' => row2["tcp_urg"],
                    'tcp_off' => row2["tcp_off"],
                    'tcp_hlen' => row2["tcp_hlen"],
                    'tcp_seq' => row2["tcp_seq"],
                    'tcp_sum' => row2["tcp_sum"],
                    'tcp_sport' => row2["tcp_sport"],
                    'tcp_urp' => row2["tcp_urp"],
                    'tcp_win' => row2["tcp_win"]
                  }
              }
              pcktyaml = pcktdata.to_yaml
              q = @ch.queue("#{@queueprefix}_tcppacket")
              @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)
            end
            # UDP Packet
            #puts "Process UDP Data"
            udppacketsqlcount = "SELECT COUNT(*) as num FROM #{@tblname_udppacket} WHERE guid = '#{guid}'"
            res3count = @conn.query("#{udppacketsqlcount}")
            row3count = res3count.fetch_hash
            udpcount = row3count["num"]
            #puts "UDP Record Count: #{udpcount}" if udpcount.to_i > 0
            udppacketsql = "SELECT * FROM #{@tblname_udppacket} WHERE guid = '#{guid}'"
            res3 = @conn.query("#{udppacketsql}")
            while row3 = res3.fetch_hash do
              if v == 100
                puts "UDP: MSGID: #{n} GUID: #{guid}"
                v = 0
              end
              v = v + 1 unless v == 100
              pcktdata = { 'udppacket' => {
                      'guid' => row3["guid"],
                      'recv_date' => row3["recv_date"],
                      'udp_dport' => row3["udp_dport"],
                      'udp_len' => row3["udp_len"],
                      'udp_sum' => row3["udp_sum"],
                      'udp_sport' => row3["udp_sport"]
                    }
                }
                pcktyaml = pcktdata.to_yaml
                q = @ch.queue("#{@queueprefix}_udppacket")
                @ch.default_exchange.publish("#{pcktyaml}", :routing_key => q.name)
            end
            n = n + 1
        end
      end
    end

    def dbclose
      if @conn.autocommit == false; @conn.commit; end
      @conn.save
      @conn.release
      @conn.close
    end
    
  end
  
  # Bulk load from queue YAML into Database
   
  class Consumer < DataServices
  
    def from_mq_to_db
      # TODO: Test this.
      # Process ippacket queue first.
      n = 0
      # Using AMQP Gem here as Bunny never exits the thread so i can't move on to TCP / UDP probably migrate all to this gem.
      banner = "\e[1;34mStage 1: Load IP Packet data \e[0m\ \n"
      banner << "\e[1;34m=================================\e[0m\ \n"
      puts banner
      EM.run do
        connection = AMQP.connect(:host => "#{@mqhost}", :user => "#{@mquser}", :pass => "#{@mqpass}", :vhost => "#{@mqvhost}")
        puts "Connected to AMQP broker. Running #{AMQP::VERSION}"
        channel  = AMQP::Channel.new(connection)
        puts "Queue: #{@queueprefix}_ippacket"
        queue    = channel.queue("#{@queueprefix}_ippacket")
        exchange = channel.direct("")
        t = 0
        queue.bind("#{@queueprefix}_ippacket").subscribe do |metadata, body|
            #puts "MSGID: [#{n}] Received #{body}"
            ipdata = YAML.load(body).to_a
            ipdatadim = ipdata[0][1]
            ip_packet = "INSERT INTO #{@tblname_ippacket} "
            ip_packet << "(guid, recv_date, ip_df, ip_dst, ip_hlen, ip_id, ip_len, ip_mf, ip_off, ip_proto, ip_src, ip_sum, ip_tos, ip_ttl, ip_ver) "
            ip_packet << "VALUES ("
            ip_packet << "'#{ipdatadim["guid"]}',"
            ip_packet << "'#{ipdatadim["recv_date"]}',"
            ip_df = ipdatadim["ip_df"].to_s # Due to TrueClass issues will have a look later
            if ip_df == "true" 
              ip_packet << "'Y',"
            else
              ip_packet << "'N',"
            end
            ip_packet << "'#{ipdatadim["ip_dst"]}',"
            ip_packet << "'#{ipdatadim["ip_hlen"]}',"
            ip_packet << "'#{ipdatadim["ip_id"]}',"
            ip_packet << "'#{ipdatadim["ip_len"]}',"
            ip_mf = ipdatadim["ip_mf"].to_s
            if ip_mf == "true"
              ip_packet << "'Y',"
            else
              ip_packet << "'N',"
            end
            ip_packet << "'#{ipdatadim["ip_off"]}',"
            ip_packet << "'#{ipdatadim["ip_proto"]}',"
            ip_packet << "'#{ipdatadim["ip_src"]}',"
            ip_packet << "'#{ipdatadim["ip_sum"]}',"
            ip_packet << "'#{ipdatadim["ip_tos"]}',"
            ip_packet << "'#{ipdatadim["ip_ttl"]}',"
            ip_packet << "'#{ipdatadim["ip_ver"]}');"
            if t == 50
              puts "\e[1;32m\ MSGID:\e[0m\ [#{n}] \e[1;32m\Generated SQL:\e[0m\ #{ip_packet}"
              t = 0
            end
            t = t + 1 unless t == 50
            res = @conn.query("#{ip_packet}")
            @conn.save
            n = n + 1
            connection.close { EventMachine.stop }
        end
      end
      ipcount = n
      @conn.release
      @conn.commit
        
      # TCP Packet
      n = 0
      banner = "\e[1;34mStage 2: Load TCP Packet data \e[0m\ \n"
      banner << "\e[1;34m=================================\e[0m\ \n"
      puts banner
      EM.run do
        connection = AMQP.connect(:host => "#{@mqhost}", :user => "#{@mquser}", :pass => "#{@mqpass}", :vhost => "#{@mqvhost}")
        puts "Connected to AMQP broker. Running #{AMQP::VERSION}"
        channel  = AMQP::Channel.new(connection)
        puts "Queue: #{@queueprefix}_tcppacket"
        queue    = channel.queue("#{@queueprefix}_tcppacket")
        exchange = channel.direct("")
        t = 0
        queue.bind("#{@queueprefix}_tcppacket").subscribe do |metadata, body|
          #puts "MSGID: [#{n}] Received #{body}"
          tcpdata = YAML.load(body).to_a
          tcpdatadim = tcpdata[0][1]
          tcp_packet = "INSERT INTO #{@tblname_tcppacket} "
          tcp_packet << "(guid, recv_date, tcp_data_len, tcp_dport, tcp_ack, tcp_fin, tcp_syn, tcp_rst, tcp_psh, tcp_urg, tcp_off, tcp_hlen, tcp_seq, tcp_sum, tcp_sport, tcp_urp, "
          tcp_packet << "tcp_win) "
          tcp_packet << "VALUES ("
          tcp_packet << "'#{tcpdatadim["guid"]}',"
          tcp_packet << "'#{tcpdatadim["recv_date"]}', "
          tcp_packet << "#{tcpdatadim["tcp_data_len"]},"
          tcp_packet << "#{tcpdatadim["tcp_dport"]},"
          tcp_ack = tcpdatadim["tcp_ack"].to_s
          if tcp_ack == "true" 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_fin = tcpdatadim["tcp_fin"].to_s
          if tcp_fin == "true"
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_syn = tcpdatadim["tcp_syn"].to_s
          if tcp_syn == "true" 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_rst = tcpdatadim["tcp_rst"].to_s
          if tcp_rst == "true" 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_psh = tcpdatadim["tcp_psh"].to_s
          if tcp_psh == "true" 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_urg = tcpdatadim["tcp_urg"].to_s
          if tcp_urg == "true"
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_packet << "#{tcpdatadim["tcp_off"]}, #{tcpdatadim["tcp_hlen"]}, #{tcpdatadim["tcp_seq"]}, #{tcpdatadim["tcp_sum"]}, #{tcpdatadim["tcp_sport"]}, #{tcpdatadim["tcp_urp"]}, #{tcpdatadim["tcp_win"]});"
          if t == 50
            puts "\e[1;32m\ MSGID:\e[0m\ [#{n}] \e[1;32m\Generated SQL:\e[0m\ #{tcp_packet}"
            t = 0
          end
          t = t + 1 unless t == 50
          res = @conn.query("#{tcp_packet}")
          @conn.save
          n = n + 1
          connection.close { EventMachine.stop }
        end
      end
      tcpcount = n
      @conn.release
      @conn.commit
      
      # UDP Packet
      n = 0
      banner = "\e[1;34mStage 2: Load UDP Packet data \e[0m\ \n"
      banner << "\e[1;34m=================================\e[0m\ \n"
      puts banner
      EM.run do
        connection = AMQP.connect(:host => "#{@mqhost}", :user => "#{@mquser}", :pass => "#{@mqpass}", :vhost => "#{@mqvhost}")
        puts "Connected to AMQP broker. Running #{AMQP::VERSION}"
        channel  = AMQP::Channel.new(connection)
        puts "Queue: #{@queueprefix}_udppacket"
        queue    = channel.queue("#{@queueprefix}_udppacket")
        exchange = channel.direct("")
        t = 0
        queue.bind("#{@queueprefix}_udppacket").subscribe do |metadata, body|        
          #puts "MSGID: [#{n}] Received #{body}"
          udpdata = YAML.load(body).to_a
          udpdatadim = udpdata[0][1]
          udp_packet = "INSERT INTO #{@tblname_udppacket} "
          udp_packet << "(guid,"
          udp_packet << "recv_date,"
          udp_packet << "udp_dport,"
          udp_packet << "udp_len,"
          udp_packet << "udp_sum,"
          udp_packet << "udp_sport) "
          udp_packet << "VALUES ("
          udp_packet << "'#{udpdatadim["guid"]}',"
          udp_packet << "'#{udpdatadim["recv_date"]}',"
          udp_packet << "'#{udpdatadim["udp_dport"]}',"
          udp_packet << "'#{udpdatadim["udp_len"]}',"
          udp_packet << "'#{udpdatadim["udp_sum"]}',"
          udp_packet << "'#{udpdatadim["udp_sport"]}');"
          if t == 50
            puts "\e[1;32m\ MSGID:\e[0m\ [#{n}] \e[1;32m\Generated SQL:\e[0m\ #{udp_packet}"
            t = 0
          end
          t = t + 1 unless t == 50
          res = @conn.query("#{udp_packet}")
          @conn.save
          n = n + 1
          connection.close { EventMachine.stop }
        end
      end
      udpcount = n
      @conn.release
      @conn.commit
      totals = "\e[1;31m=======================================================================\e[0m\ \n"
      totals << "\e[1;31mPackets Total | IP: #{ipcount} | TCP: #{tcpcount} | UDP: #{udpcount}\e[0m\ \n"
      totals << "\e[1;31m======================================================================\e[0m\ \n"
      puts totals
      
    end
  
    def infinite
      puts "\e[1;31mStarting Consumer in infinite mode"
      puts "\e[1;31m==================================\n"
      puts "NOTE: Only should be used for live captures\n"
      loop {
        from_mq_to_db
      }
    end
    
    def passes(passes)
      puts "\e[1;31mStarting Consumer for #{passes} passes"
      puts "\e[1;31m======================================="
      passes.times {
        from_mq_to_db
      }
    end
    
  end

  # Process data from / to local files.
  
  class Localmachine < DataServices
  
    def from_pcap_to_disk(interface, dumpfile)
      puts "Capturing Live data... "
      begin
        capture = PCAPRUB::Pcap.open_live("#{interface}", 65535, true, 0)
        puts "Writing to file ..."
        puts "Press CTRL+C to exit ..."
        dumper = capture.dump_open("#{dumpfile}")
        capture_packets = 100
        capture.each {|pkt|
          capture.dump(pkt.length, pkt.length, pkt)
        }
        capture.dump_close
      rescue
        puts "Make sure the interface name is correct and you have enough disk space"
        exit
      end      
    end
    
    def from_pcap_db(pcapfile)
      t, n, s, v, x, z = 0, 0, 0, 0, 0, 0
      ipcount, tcpcount, udpcount = 0, 0, 0
      inp = Pcap::Capture.open_offline(pcapfile)
      inp.each_packet do |pkt|
        guid = Tools::guid # IP / TCP / UDP relationship
        dtime = Time.now
        # IP Packet
        if pkt.ip?
            ip_packet = "INSERT INTO #{@tblname_ippacket} "
            ip_packet << "(guid, recv_date, ip_df, ip_dst, ip_hlen, ip_id, ip_len, ip_mf, ip_off, ip_proto, ip_src, ip_sum, ip_tos, ip_ttl, ip_ver) "
            ip_packet << "VALUES ("
            ip_packet << "'#{guid}',"
            ip_packet << "'#{dtime}',"
            if pkt.ip_df? == true 
              ip_packet << "'Y',"
            else
              ip_packet << "'N',"
            end
            ip_packet << "'#{pkt.ip_dst}',"
            ip_packet << "'#{pkt.ip_hlen}',"
            ip_packet << "'#{pkt.ip_id}',"
            ip_packet << "'#{pkt.ip_len}',"
            if pkt.ip_mf? == true
              ip_packet << "'Y',"
            else
              ip_packet << "'N',"
            end
            ip_packet << "'#{pkt.ip_off}',"
            ip_packet << "'#{pkt.ip_proto}',"
            ip_packet << "'#{pkt.ip_src}',"
            ip_packet << "'#{pkt.ip_sum}',"
            ip_packet << "'#{pkt.ip_tos}',"
            ip_packet << "'#{pkt.ip_ttl}',"
            ip_packet << "'#{pkt.ip_ver}');"
            if t == 50
              puts "\e[1;32m\ MSGID:\e[0m\ [#{n}] \e[1;32m\Generated SQL:\e[0m\ #{ip_packet}"
              t = 0
            end
            t = t + 1 unless t == 50
            res = @conn.query("#{ip_packet}")
            @conn.save
            n = n + 1
        end
        # TCP Packet
        if pkt.tcp?
          tcp_packet = "INSERT INTO #{@tblname_tcppacket} "
          tcp_packet << "(guid, recv_date, tcp_data_len, tcp_dport, tcp_ack, tcp_fin, tcp_syn, tcp_rst, tcp_psh, tcp_urg, tcp_off, tcp_hlen, tcp_seq, tcp_sum, tcp_sport, tcp_urp, "
          tcp_packet << "tcp_win) "
          tcp_packet << "VALUES ("
          tcp_packet << "'#{guid}',"
          tcp_packet << "'#{dtime}', "
          tcp_packet << "#{pkt.tcp_data_len},"
          tcp_packet << "#{pkt.tcp_dport},"
          if pkt.tcp_ack? == true 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          if pkt.tcp_fin? == true
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          if pkt.tcp_syn? == true 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          if pkt.tcp_rst? == true 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          if pkt.tcp_psh? == true 
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          if pkt.tcp_urg? == true
            tcp_packet << "'Y',"
          else
            tcp_packet << "'N',"
          end
          tcp_packet << "#{pkt.tcp_off}, #{pkt.tcp_hlen}, #{pkt.tcp_seq}, #{pkt.tcp_sum}, #{pkt.tcp_sport}, #{pkt.tcp_urp}, #{pkt.tcp_win});"
          if s == 50
            puts "\e[1;32m\ MSGID:\e[0m\ [#{v}] \e[1;32m\Generated SQL:\e[0m\ #{tcp_packet}"
            s = 0
          end
          s = s + 1 unless s == 50
          res = @conn.query("#{tcp_packet}")
          @conn.save
          v = v + 1        
        end
        # UDP Packet
        if pkt.udp?
          udp_packet = "INSERT INTO #{@tblname_udppacket} "
          udp_packet << "(guid,"
          udp_packet << "recv_date,"
          udp_packet << "udp_dport,"
          udp_packet << "udp_len,"
          udp_packet << "udp_sum,"
          udp_packet << "udp_sport) "
          udp_packet << "VALUES ("
          udp_packet << "'#{guid}',"
          udp_packet << "'#{dtime}',"
          udp_packet << "'#{pkt.udp_dport}',"
          udp_packet << "'#{pkt.udp_len}',"
          udp_packet << "'#{pkt.udp_sum}',"
          udp_packet << "'#{pkt.udp_sport}');"
          if x == 50
            puts "\e[1;32m\ MSGID:\e[0m\ [#{z}] \e[1;32m\Generated SQL:\e[0m\ #{udp_packet}"
            x = 0
          end
          x = x + 1 unless x == 50
          res = @conn.query("#{udp_packet}")
          @conn.save
          z = z + 1        
        end
        ipcount = n
        tcpcount = v
        udpcount = z
      end
      @conn.release
      @conn.commit
      totals = "\e[1;31m=======================================================================\e[0m\ \n"
      totals << "\e[1;31mPackets Total | IP: #{ipcount} | TCP: #{tcpcount} | UDP: #{udpcount}\e[0m\ \n"
      totals << "\e[1;31m======================================================================\e[0m\ \n"
      puts totals
    end
    
  end
  
end

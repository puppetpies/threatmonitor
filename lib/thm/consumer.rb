
trap("INT") {
  
  if EM.reactor_running? == true
    puts "Exiting Reactor thread ..."
    EventMachine.stop
  end
  exit
}

module Thm
  
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

end

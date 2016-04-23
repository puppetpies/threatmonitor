########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries
#
#   Remote to Local Pcap operations
#
########################################################################

module Thm

  # Process data from / to local files.
  
  class Localmachine < DataServices
  
    # We have to use a different Gem here called pcaprub that supports live interface / dumping mode.
    
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
        raise Exception, "Make sure the interface name is correct and you have enough disk space"
        exit
      end      
    end
    
    # We can inject packets into an interface DANGEROUS !!!
    
    def from_pcap_to_interface_injection(interface, inputdumpfile)
      # NOTES
      # Src / Dst rewriting ip_src, ip_dst
    end
    
    # From Pcap file to Datastore
    
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

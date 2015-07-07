module Thm
  # Send data else were
  
  class Producer < DataServices
    
    def from_interface_to_mq(interface, pcapfilters="")
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

end

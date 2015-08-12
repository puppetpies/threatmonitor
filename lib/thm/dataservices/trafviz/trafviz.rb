module Thm

  class DataServices::Trafviz

    def makeurl(data)
      if !request_valid?(data)
        return false
      end
      hdrs = data
      hostn, requestn = ""
      hdrs.each_line {|n|
        if n.split(":")[0] == "Host"
          hostn = n.split(":")[1].strip
        elsif n.split(" ")[0] == "GET"
          requestn = n.split(" ")[1]
        end
      }
      puts "\e[1;37mURL: http://#{hostn}#{requestn} \e[0m\ "
    end

    # Check if a request isn't just a GET line without headers
    # Not sure if this is valid HTTP
    def request_valid?(data)
      ln = 0
      data.each_line {|l|
        ln += 1
      }
      if ln > 1
        return true
      else
        puts "\e[1;31mCatch GET's without header information \e[0m\ "
        return false # Due to single GET Requests to no headers 
      end
    end

    # Filter request data and build query
    def request_filter(reqtable, data, keysamples=2000)
      if !request_valid?(data)
        sql = "SELECT 1;"
        return sql
      end
      lkey, rkey = ""
      t = 0
      sql = "INSERT INTO #{reqtable} (guid,"
      cols, vals = String.new, String.new
      guid = Tools::guid
      vals = "'#{guid}',"
      data.each_line {|n|
        unless n.strip == ""
          if t > 0 # Don't processes GET / POST Line
            lkey = n.split(":")[0].downcase.gsub("-", "").to_s.strip
            #puts "LKEY: #{lkey}"
            if lkey == "cookie"
              rkeyenc = "cookieommited"
            else
              rkey = n.split(":")[1].to_s.gsub(",", "").gsub(";", "").gsub("=", "").strip
              rkeyenc = URI.encode(rkey)
            end
            if ((rkey.strip != "" or lkey.strip != "") and (lkey.strip != "range"))
              cols << "#{lkey},"
              vals << "'#{rkey}',"
            end
            # Keycounter / HTTP Headers counter
            if @countheaders == true
              # Keysamples: For Headers counter number of output lines to sample before exit.
              if @f < keysamples
                if lkey != ""
                  @k.keycount("#{lkey}")
                  @f = @f + 1
                  puts "Sample ##{@f} of##{keysamples}" 
                end
              else
                pp @k.keycount_compile
                @k.keycount_createtablethm
                puts "Real exit..."
                exit
              end
            end
          end
          t = t + 1
        end
      }
      # SQL for Datastore
      begin
        cols = "#{cols[0..cols.size - 2]}) "
        vals = "#{vals[0..vals.size - 2]});"
        sql = "#{sql}#{cols}VALUES (#{vals}"
        return sql
      rescue => e
        pp e
      end
    end

    def text_highlighter(text)
      keys = ["Linux", "Java", "Android", "iPhone", "Mobile", "Chrome", 
              "Safari", "Mozilla", "Gecko", "AppleWebKit", "Windows", 
              "MSIE", "Win64", "Trident", "wispr", "PHPSESSID", "JSESSIONID",
              "AMD64", "Darwin", "Macintosh", "Mac OS X", "Dalvik"]
      cpicker = [2,3,4,1,7,5,6]
      keys.each {|n|
        text.gsub!("#{n}", "\e[4;3#{cpicker[rand(cpicker.size)]}m#{n}\e[0m\ \e[0;32m".strip)
      }
      return text
    end

  end

end

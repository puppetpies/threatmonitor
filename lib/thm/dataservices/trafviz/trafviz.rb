require 'keycounter'

class Keycounter
  
  # Essentially custom def for this program
  def keycount_createtablethm
    fieldlst = Array.new
    if File.exists?("/tmp/thmreadtable.txt")
      File.open("/tmp/thmreadtable.txt", 'r') {|n|
        n.each_line {|l|
          fieldlst << ["#{l}"]
        }
      }
    end
    sql = "CREATE TABLE http_request (\n"
    sql << "guid char(36),\n"
    instance_variables.each {|n|
      t = n.to_s.gsub("@", "")
      fieldlst << ["#{t}"]
    }
    fieldlst.each {|n|
      sql << "#{n} string,\n"
    }
    sql = sql[0..sql.size - 2]
    sql << "\n);\n"
    b = fieldlst.uniq.sort
    pp b
    File.open("/tmp/thmreadtable.txt", 'w') {|n|
      b.each {|j|
        n.puts(j)
      }
    }
    puts "\e[4;36mCreate table:\e[0m\ \n #{sql}"
  end
  
end

module Thm

  class DataServices::Trafviz

    attr_writer :countheaders
    
    def initialize
      @k = Keycounter.new
      @countheaders = false
      @snum = 0
    end
    
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

    # Cookie ommit as we don't want to steal cookie data and pointless to store.
    def filter_header?(lkey)
      case lkey
      when "cookie"
        return "cookieommited"
      end
    end
    
    # Right Cell eval
    def rkey_encode(rkey)
      rkeyenc = URI.encode(rkey)
    end
    
    # Filter lkey = header, rkey = requestdata
    def lkey_strip(hdrs)
      hdrs.split(":")[0].downcase.gsub("-", "").to_s.strip
    end
    
    def rkey_strip(data)
      data.split(":")[1].to_s.gsub(",", "").gsub(";", "").gsub("=", "").strip
    end
    
    # Filter request data and build query
    def request_filter(reqtable, data, keysamples=2000)
      if !request_valid?(data)
        sql = "SELECT 1;"
        return sql
      end
      guid = Tools::guid
      cols, vals = String.new, String.new
      lkey, rkey = String.new, String.new
      t = 0
      sql = "INSERT INTO #{reqtable} (guid,"
      vals = "'#{guid}',"
      data.each_line {|n|
        unless n.strip == ""
          if t > 0 # Don't processes GET / POST Line
            lkey = lkey_strip(n)
            rkey = rkey_strip(n)
            rkeyenc = filter_header?(lkey)
            if rkeyenc != "cookieommited"
              rkeyenc = rkey_encode(rkey)
            end
            if ((rkey.strip != "" or lkey.strip != "") and (lkey.strip != "range"))
              cols << "#{lkey},"
              vals << "'#{rkey}',"
            end
            # Keycounter / HTTP Headers counter
            if @countheaders == true
              # Keysamples: For Headers counter number of output lines to sample before exit.
              # snum gets incremented so each request increments an instance variable to it keeps it position per request
              if @snum < keysamples
                if lkey != ""
                  @k.keycount("#{lkey}")
                  @snum += 1
                  puts "Sample ##{@snum} of ##{keysamples}" 
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

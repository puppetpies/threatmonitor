########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Dashboard
#
# Database Connectivity Essential to the project
#
########################################################################

module DatalayerLight

  class MonetDBDrv
    
    require 'MonetDB'
    
    attr_writer :hostname, :username, :password, :port, :debug, :autocommit
    attr_accessor :dbname
    
    def initialize
      @hostname = "127.0.0.1"
      @username = "monetdb"
      @password = "monetdb"
      @port = 50000
      @dbname = "demo"
      @debug = 1
      @autocommit = true
    end

    def connect
      @db = MonetDB.new
      if @debug == 1
        puts "Hostname: #@hostname"
        puts "Username: #@username"
        puts "Password: #@password"
        puts "Port:     #@port"
        puts "Dbname:   #@dbname"
      end
      @db.connect(user = "#@username", 
          passwd = "#@password", 
          lang = "sql", 
          host="#@hostname", 
          port = @port, 
          db_name = "#@dbname", 
          auth_type = "SHA256")
      @db.auto_commit(@autocommit)
    end
    
    def save
      @db.save
    end
    
    def release
      @db.release
    end
    
    def is_connected?
      @db.is_connected?
    end
    
    def auto_commit?
      @db.auto_commit?
    end
    
    def commit
      @db.query("COMMIT;")
    end
    
    def query(sql)
      @res = @db.query("#{sql};")
      if @debug == 1; puts "#{sql}"; end
      return @res
    end
    
    def free
    @res.free
    end
    
    def close
      @db.close
    end

  end

  # Fine for small capture projects
  class MySQLDrv
    
    require 'mysql'
    
    attr_writer :hostname, :username, :password, :port, :debug, :autocommit
    attr_accessor :dbname
    
    def initialize
      @hostname = "127.0.0.1"
      @username = "guest"
      @password = ""
      @port = 3306
      @dbname = "test"
      @debug = 1
      @autocommit = true
    end

    def connect
      @db = Mysql.init
      if @debug == 0
        puts "Hostname: #@hostname"
        puts "Username: #@username"
        puts "Password: #@password"
        puts "Port:     #@port"
        puts "Dbname:   #@dbname"
      end
      @db.connect("#@hostname", 
                  "#@username", 
                  "#@password", 
                  "#@dbname", 
                  @port)
      @db.autocommit(@autocommit)
    end

    def query(sql)
      begin
        @res = @db.query("#{sql;}")
        if @debug == true; puts "#{sql}"; end
        return @res
      rescue Mysql::Error => e
        puts e
      end 
    end
    
    # Just a work around for functions that don't exist in MySQL
    def save; end
    def release; end 
    
    def commit
      @db.commit
    end
    
    def close
      @db.close
    end
    
  end

  # Metrics / Measurements Engine InfluxDB RestAPI
  class InfluxDB

    require "net/http"
    require "uri"
    require "json"
    require "pp"
  
    attr_accessor :dbhost, :dbuser, :dbpass, :dbport, :dburl, :dbname

    def initialize
      @dbhost = "127.0.0.1"
      @dbuser = "threatmonitor"
      @dbpass = "dk3rbi9l"
      @dbport = 8086
      @dbname = "threatmonitor"
    end
    
    def apiget(sql)
      @dburl = "http://#{@dbhost}:#{@dbport}"
      sqlunicode = URI.encode(sql)
      puts "InfluxDB SQL URL: #{@dburl}/query?db=#{@dbname}&q=#{sqlunicode}"
      uri = URI.parse("#{@dburl}/query?db=#{@dbname}&q=#{sqlunicode}")
      puts "Request URI: #{uri}"
      http = Net::HTTP.new(uri.host, uri.port)
      begin
        response = http.request(Net::HTTP::Get.new(uri.request_uri))
        begin
          j = JSON.parse(response.body)
        rescue JSON::ParserError
          puts "Could not read JSON data"
        end
      rescue
        puts "Error retrieving data"
      end
    end
    
    def apipost(data)
      @dburl = "http://#{@dbhost}:#{@dbport}"
      #puts "InfluxDB SQL URL: #{@dburl}/query?db=#{@dbname}"
      uri = URI.parse("#{@dburl}/write?db=#{@dbname}")
      #puts "Request URI: #{uri}"
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_content_type("application/x-www-form-urlencoded")
      begin
        request.body = data unless data.empty?
        response = http.request(request)
        if response.code == "204" # Good response
          # Be quiet
          return response.code
        elsif response.code =~ %r=[200,400,500]= # 200 can be an error in some cases !!
          puts "Error code #{response.code}"
          return response.code
        end
      rescue
        puts "Error posting data"
        return "404"
      end
    end
    
    def query(sql, mode="r")
      if mode == "r"
        apiget("#{sql}")
      elsif mode == "w"
        apipost(sql)
      end
    end
    
  end

end

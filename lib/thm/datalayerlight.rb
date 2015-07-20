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
  
end

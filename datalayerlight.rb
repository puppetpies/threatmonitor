########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor Dashboard
#
# MonetDB Connectivity Essential to the project
#
########################################################################

class DatalayerLight
  
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
    return @res
  end
  
  def free
	@res.free
  end
  
  def close
    @db.close
  end

end

module Thm

  class DataServices

    #  This class provides all the core functionality to the lower level DatalayerLight
    #
    #  Example variables
    #
    #  obj = Thm::Producer.new
    #  obj.mqhost = "127.0.0.1"
    #  obj.mquser = "test"
    #  obj.mqpass = "setone"
    #  obj.mqconnect
    #  obj.dbconnect
    
    attr_accessor :autocommit, :datastore, :mqhost, :mquser, :mqpass, :mqvhost, :dbhost, :dbuser, :dbpass, :dbname, :queueprefix, :tblname_ippacket, :tblname_tcppacket, :tblname_udppacket
    
    def initialize
      @autocommit = false
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
      @conn.autocommit = @autocommit
      begin
        @conn.connect
      rescue Errno::ECONNREFUSED
        puts "Database not running!"
        puts "Bye!"
        exit
      end
    end
    
    def query(sql)
      res = @conn.query("#{sql}")
    end

  end

end

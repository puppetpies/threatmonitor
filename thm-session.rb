########################################################################
#
# Author: Brian Hood
#
# Description: Threatmonitor User Administration / Dashboard
# Codename: Deedrah
#
# Extends the functionality of the Thm module adding Authorization
# Adding Session Login / Sinatra / Web Interface functionality
#
########################################################################

require 'rubygems' if RUBY_VERSION < "1.9"
require 'chartkick'
require 'sinatra/base'
require 'slim'
require "#{File.dirname(__FILE__)}/thm-authentication.rb"

RELEASE = "Deedrah"

class Sinatra::Base

  class << self
  
    def getpost(path, opts={}, &block)
      get(path, opts, &block)
      post(path, opts, &block)
    end
    
  end
  
end


class Geocounter

  # Create / Add to instance variable
  def geocount(country)
    country.gsub!(" ", "_") # no spaces or case
    if !instance_variable_get("@#{country}")
      instance_variable_set("@#{country}", 1)
    else
      instance_variable_set("@#{country}", instance_variable_get("@#{country}") + 1)
    end
    puts "Country: #{country} Value: "+instance_variable_get("@#{country}").to_s
  end

  # Read a single country
  def geocount_reader(country)
    country.gsub!(" ", "_") # no spaces or case
    valnum = instance_variable_get("@#{country}")
    return valnum
  end

  # Compile in array with the totals of all instance variables
  def geocount_compile
    countrycounts = Array.new
    instance_variables.each {|n|
      t = n.to_s.gsub("@", "")
      countrycounts << ["#{t}", instance_variable_get("#{n}")]
    }
    return countrycounts
    countrycounts
  end

end

module ThmUI extend self

  class Deedrah < Sinatra::Base

    attr_reader :thmsession
    
    include Chartkick::Helper
    
    set :server, :puma
    set :logging, :true
	
    configure do
      enable :session
    end
    
    before do
      content_type :html
    end
	
    set :title, "Threatmonitor - Packet Analysis Suite #{RELEASE}"
    set :port, 4567
    set :bind, "0.0.0.0"
    
    def objstart!
      @sessobj = Thm::Authorization::Authentication.new
      @sessobj.datastore = "monetdb"
      @sessobj.dbconnect
    end
    
    # NOTE: Monkey patch Sinatra initialize
    #       If you go to /dashboard without logging in @sessobj it won't have been created
    #       So if you create it objstart! in the Sinatra's initialize your sorted.
    #       Page requests will come in a @sessobj will always exist and be the same one no headaches 
    def initialize(app = nil)
      super()
      objstart! # Little trick here patch so i can get objstart! out of the box!
      @app = app 
      @template_cache = Tilt::Cache.new
      yield self if block_given?
    end

    def login_session?
      if @sessobj.login_session? == false
        puts "Not logged in"
      else
        return true
      end
    end
    
    def get_session_info?
      puts "Sinatra: #{Sinatra::VERSION} / Thmsession: #{@sessobj.thmsession}"
    end
    
    def login(username, password)
      @sessobj.login("#{username}", "#{password}")
      if login_session?
        puts "\e[1;32m\Welcome to Threatmonitor \e[0m\ "
        puts "Thm Session: #{@sessobj.thmsession}"
        return true
      else
        return false
      end
    end
     
    def logout
      @sessobj.thmsesslock = "DEADBEEF"
    end
    
    def login_lock?
      if @sessobj.thmsesslock != "OK"
        puts "Session doesn't exist redirecting to Login..."
        redirect '/'
      end
    end
    
    # Sinatra routings
    
    getpost '/' do
      if params[:submit] != nil
        @sessthm = login(params[:username], params[:password])
      end
      if @sessobj.thmsesslock == "OK"
        puts "Session created redirecting to Dashboard ..."
        redirect '/dashboard'
      end
      slim :authenticate
    end
    
    def geoiplookup(ip)
      query = "SELECT continent_name, country_name FROM geoipdata_ipv4blocks_country a JOIN geoipdata_locations_country b ON (a.geoname_id = b.geoname_id) WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.country_name LIMIT 1;"
      resusrcnt = @sessobj.query("#{query}")
      while row = resusrcnt.fetch_hash do
        continent_name = row["continent_name"].to_s
        country_name = row["country_name"].to_s
        #if continent_name == ""
          cname = "(#{country_name})"
        #else
        #  cname = "(#{continent_name})"
        #end
      end
     # geoipcount(
      return cname
    end
    
    getpost '/dashboard' do
      #login_lock?
      query = "select count(*) as num2,  ip_dst from wifi_ippacket a JOIN wifi_udppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.udp_dport) where udp_dport > 0 and udp_dport < 10000 and s.protocol = 'UDP' and ip_dst not in ('255.255.255.255') group by b.udp_dport, a.ip_dst;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt = Array.new
      while row = resusrcnt.fetch_hash do
        num2 = row["num2"].to_s
        ip_dst = row["ip_dst"].to_s
        location = geoiplookup(ip_dst)
        @gcnt = Geocounter.new
        locfix = location.to_s.gsub("(", "").gsub(")", "") # Yawn
        if location != nil or location == ""
          @gcnt.geocount("#{locfix}")
        end
        @rowusrcnt << ["#{ip_dst} #{location}", "#{num2}"]
      end
      # TCP
      query = "select count(*) as num2,  ip_dst from wifi_ippacket a JOIN wifi_tcppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.tcp_dport) where tcp_dport > 0 and tcp_dport < 10000 and s.protocol = 'TCP' and ip_dst not in ('255.255.255.255') group by b.tcp_dport, a.ip_dst;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt2 = Array.new
      while row = resusrcnt.fetch_hash do
        num2 = row["num2"].to_s
        ip_dst = row["ip_dst"].to_s
        location = geoiplookup(ip_dst)
        locfix = location.to_s.gsub("(", "").gsub(")", "") # Yawn
        if location != nil or location == ""
          @gcnt.geocount("#{locfix}")
        end
        @rowusrcnt2 << ["#{ip_dst} #{location}", "#{num2}"]
      end
      # Service chart UDP
      query = "select num, description, count(*) as num2 from wifi_ippacket a JOIN wifi_udppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.udp_dport) where udp_dport > 0 and udp_dport < 10000 and s.protocol = 'UDP' and ip_dst not in ('255.255.255.255') group by b.udp_dport, a.ip_dst, s.description, s.num;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt3 = Array.new
      while row = resusrcnt.fetch_hash do
        num = row["num"].to_s
        desc = row["description"].to_s
        count = row["num2"].to_s
        @rowusrcnt3 << ["#{desc} (#{num})", "#{count}"]
      end
      # Service chart TCP
      query = "select num, description, count(*) as num2 from wifi_ippacket a JOIN wifi_tcppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.tcp_dport) where tcp_dport > 0 and tcp_dport < 10000 and s.protocol = 'TCP' and ip_dst not in ('255.255.255.255') group by b.tcp_dport, a.ip_dst, s.description, s.num;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt4 = Array.new
      while row = resusrcnt.fetch_hash do
        num = row["num"].to_s
        desc = row["description"].to_s
        count = row["num2"].to_s
        @rowusrcnt4 << ["#{desc} (#{num})", "#{count}"]
      end
      # Top TCP/IP Talkers
      query = "select count(*) as num2, tcp_dport, ip_dst from wifi_ippacket a JOIN wifi_tcppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.tcp_dport) where tcp_dport > 0 and tcp_dport < 10000 and s.protocol = 'TCP' and ip_dst not in ('255.255.255.255') group by b.tcp_dport, a.ip_dst order by num2 desc;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt5 = Array.new
      while row = resusrcnt.fetch_hash do
        ip_dst = row["ip_dst"].to_s
        num = row["tcp_dport"].to_s
        count = row["num2"].to_s
        location = geoiplookup(ip_dst)
        @rowusrcnt5 << ["#{ip_dst} #{location} (#{num})", "#{count}"]
      end
      # Top UDP/IP Talkers
      query = "select count(*) as num2, udp_dport, ip_dst from wifi_ippacket a JOIN wifi_udppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.udp_dport) where udp_dport > 0 and udp_dport < 10000 and s.protocol = 'UDP' and ip_dst not in ('255.255.255.255') group by b.udp_dport, a.ip_dst order by num2 desc;"
      resusrcnt = @sessobj.query("#{query}")
      @rowusrcnt6 = Array.new
      while row = resusrcnt.fetch_hash do
        ip_dst = row["ip_dst"].to_s
        num = row["udp_dport"].to_s
        count = row["num2"].to_s
        location = geoiplookup(ip_dst)
        @rowusrcnt6 << ["#{ip_dst} #{location} (#{num})", "#{count}"]
      end
      pp @rowusrcnt
      pp @rowusrcnt2
      pp @rowusrcnt3
      pp @rowusrcnt4
      @rowgeocount = @gcnt.geocount_compile
      puts "test"
      pp @rowusrcnt5
      pp @rowusrcnt6
      #@rowusrcnt = resusrcnt.fetch_hash
      erb :dashboard
    end
    
    get '/status' do
      # Informational / Debug
      get_session_info?
    end
    
    get '/logout' do
      # Logout and remove thmsesslock
      if @sessobj.thmsesslock == "OK"
        logout
        redirect '/'
      end
      slim :logout
    end
    
    get '/stylesheets/screen.css' do
      send_file 'stylesheets/screen.css', :type => :css
    end
    
    get '/js/chartkick.js' do
      send_file 'js/chartkick.js', :type => :js
    end

    get '/js/jquery.min.js' do
      send_file 'js/jquery.min.js', :type => :js
    end

    get '/js/JSXTransformer.js' do
      send_file 'js/JSXTransformer.js', :type => :js
    end

    get '/js/marked.min.js' do
      send_file 'js/marked.min.js', :type => :js
    end

    get '/js/react.js' do
      send_file 'js/react.js', :type => :js
    end

    get '/js/files/authenticate.jsx' do
      send_file 'js/files/authenticate.jsx', :type => :js
    end
    
    get '/js/jsapi.js' do
      send_file 'js/jsapi.js', :type => :js
    end
    
    run!
    
  end
  
end

# Start Dashboard Release

Deedrah.new

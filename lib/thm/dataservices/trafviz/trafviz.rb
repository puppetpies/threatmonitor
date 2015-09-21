########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries - Trafviz
#
#  Data parsing functionality
#
########################################################################

require 'pp'
require 'json'
require 'walltime'

module TimeWarp

  refine Stopwatch do

    def print_stats
      round = round_to(@t2 - @t1, 2)
      puts "Start: #{Time.at(@t1)} Finish: #{Time.at(@t2)} Total time: #{round}"
      diff = (Time.at(@t2) - Time.at(@t1))*1000
      puts "Difference: #{diff.to_s.gsub(".", "")[0..2]}ms"
    end
    
  end

end

module Thm
    
  class DataServices::Trafviz
    
    attr_writer :reqtable, :reqtableua, :debug
    attr_reader :makeurl_last

    # For refinement of print_stats 
    using TimeWarp
    
    def initialize
      @debug = false
      @reqtable, @reqtableua = String.new, String.new
      @makeurl_last = String.new
    end
    
    def makeurl(data)
      if !request_valid?(data)
        return false
      end 
      hostn, requestn = ""
      data.each_line {|n|
        if n.split(":")[0] == "Host"
          hostn = n.split(":")[1].strip
        elsif n.split(" ")[0] =~ /^GET|^HEAD/
          requestn = n.split(" ")[1]
        end
      }
      @makeurl_last = "http://#{hostn}#{requestn}"
      puts "\e[1;37mURL: http://#{hostn}#{requestn} \e[0m\ "
    end

    # Check if a request isn't just a GET line without headers / single line
    # Not sure if this is valid HTTP
    def request_valid?(data)
      ln = 0
      data.each_line {|l|
        ln += 1
      }
      if ln > 1
        return true
      else
        puts "\e[1;31mCatch GET's without header information / Other \e[0m\ "
        return false # Due to single GET Requests to no headers 
      end
    end
    
    # This is just an informal function when in debug mode
    def catch_header(hdrs, comment="")
      print "Caught: #{hdrs} "
      puts "Header comment: #{comment}" unless comment == ""
    end
    
    # Cookie ommit as we don't want to steal cookie data and pointless to store.
    # Other useless headers / slight issues
    # You can now add a comment to catch_header if you like
    def filter_header?(lkey)
      puts "MY LKEY: |#{lkey}|" if @debug == true
      case 
      when lkey == "cookie"
        catch_header(lkey) if @debug == true
        return true
      when lkey == "range"
        catch_header(lkey) if @debug == true
        return true
      when lkey =~ %r=^get |^post |^head =
        catch_header(lkey, "Seen this unsure why it even occurs yet !") if @debug == true
        return true
      else
        return false
      end
    end
    
    # Right Cell eval
    def rkey_decode(rkey)
      rkeyenc = URI.decode(rkey)
    end
    
    # Filter lkey = header, rkey = requestdata
    def lkey_strip(hdrs)
      hdrs.split(": ")[0].downcase.gsub("-", "").to_s.strip
    end
    
    def rkey_strip(data)
      data.split(": ")[1].to_s.strip #to_s.gsub(",", "").gsub(";", "").gsub("=", "").strip
    end
    
    # Filter request data and build query
    def request_filter(data, keysamples=2000)
      flt = Stopwatch.new
      flt.watch('start')
      if !request_valid?(data)
        sql = "SELECT 1;"
        return sql
      end
      guid = Tools::guid
      cols, vals = String.new, String.new
      lkey, rkey = String.new, String.new
      sql_ua = String.new
      json_data_pieces = String.new
      t = 0
      json_data_hdr = "@json_template = { 'http' => { "
      json_data_ftr = " } }"
      sql = "INSERT INTO #{@reqtable} (recv_time,recv_date,guid,json_data) "
      data.each_line {|n|
        unless n.strip == ""
          if t > 0 # Don't processes GET / POST Line
            lkey, rkey = lkey_strip(n), rkey_strip(n)
            puts "LKEY: #{lkey} RKEY: #{rkey}" if @debug == true
            rkeyenc = filter_header?(lkey)
            if rkeyenc == false
              rkeyenc = rkey_decode(rkey)
              if lkey == "useragent"
                ua = Tools::ua_parser(rkeyenc)
                sql_ua = "INSERT INTO #{@reqtableua} (family, "
                sql_ua << "major, minor, " unless ua.version == nil
                sql_ua << "os, guid) "
                sql_ua << "VALUES ('#{ua.family}', "
                sql_ua << "'#{ua.version.major}', '#{ua.version.minor}', " unless ua.version == nil
                sql_ua << "'#{ua.os.to_s}', '#{guid}');"
              end
            else 
              rkey = "ommited"
            end
            if rkey != "" or lkey != ""
              prerkeyins = rkey.gsub('"', '') # Strip Quotes
              prerkeyins = "blank" if prerkeyins.strip == "" # Seems JSON values can't be "accept":""
              puts "Found Blank Value!!!" if prerkeyins == "blank"
              json_data_pieces << "'#{lkey}' => \"#{prerkeyins}\",\n" if lkey != "useragent"
            end
          end
          t += 1
        end
      }
      # Store the URL in the JSON unless its blank
      # Build JSON Manually as i bet its faster than using some JSON encoder where it has to convert from Array etc.
      json_data_pieces << "'url' => \"#{@makeurl_last}\",\n" unless @makeurl_last == ""
      # SQL for Datastore
      begin
        # Remove last , to fix hash table
        json_data_pieces.sub!(%r{,\n$}, "")
        json_eval = %Q{#{json_data_hdr}#{json_data_pieces}#{json_data_ftr}}
        puts "\e[4;36mJSON Data:\e[0m\ \n#{json_eval}"
        eval(json_eval) # Unsure why a local variable works for this in IRB
        json_data = @json_template.to_json
        remove_instance_variable("@json_template") # Hence remove instance variable here
        # Added GUID as i could extend TCP/IP capture suites in the future for HTTP traffic 
        sql = "#{sql}VALUES (NOW(), NOW(), '#{guid}', '#{json_data}');"
        flt.watch('stop')
        print "\e[4;36mFilter Time Taken:\e[0m\ "
        flt.print_stats
        return [sql, sql_ua]
      rescue => e
        pp e
      end
    end
    
    include TextProcessing

  end

end

module Thm

  class DataServices::Trafviz::FilterManager

    attr_reader :bookmarks, :pcapsetfilter
    
    def initialize
      @bookmarks = Array.new
      @bkm = MyMenu.new
      @bkm.settitle("Welcome to Trafviz")
      @bkm.mymenuname = "Trafviz"
      @bkm.prompt = "Trafviz"
      @pcapsetfilter = String.new
    end

    def read(file)
      b = 0
      File.open("#{Dir.home}/.thm/#{file}", 'r') {|n|
        n.each_line {|l|
          puts "\e[1;36m#{b})\e[0m\ #{l}"
          @bookmarks[b] = l
          b += 1
        }
      }
    end

    def write(file)
      @bkm.mymenuname = "Filters"
      @bkm.prompt = "\e[1;33m\Set filter>\e[0m\ "
      pcapfilter = @bkm.definemenuitem("selectfilter", true) do
        # Just needs value returned via readline block into addfilter
      end
      fltvalid = validate_filter?("#{pcapfilter}")
      if fltvalid == true
        File.open("#{Dir.home}/.thm/#{file}", 'a') {|n| # Append to filter file
          n.puts("#{addfilter}")
        }
      end
    end
    
    def set_defaults(file)
      # Add default example filters
      File.open("#{Dir.home}/.thm/#{file}", 'w') {|n|
        n.puts("webtraffic: tcp dst port 80")
        n.puts("sourceportrange: tcp src portrange 1024-65535")
      }
    end

    def validate_filter?(filter)
      begin
        Pcap::Filter.compile("#{filter}")
        puts "Filter Compile #{filter}"
        return true
      rescue Pcap::PcapError => e
        pp e
        return false
      end
    end
    
    def build_filter_menu
      @bkm.settitle("Welcome to Trafviz")
      @bkm.mymenuname = "Trafviz"
      @bkm.prompt = "Trafviz"
      @bkm.debug = 3
      pp @bookmarks
      @bookmarks.each {|n|
        func_name = n.split(":")[0]
        pcap_filter = n.split(":")[1].lstrip
        puts "#{pcap_filter}"
        # Instance Eval probably nicer
        fltvalid = validate_filter?("#{pcap_filter}") # Because validate_filter? won't exist inside instance_eval
        @bkm.instance_eval do
          pp fltvalid
          if fltvalid == true
            definemenuitem("#{func_name}") do
              @pcapsetfilter = "#{pcap_filter}"
              #thm = DataServices::Trafviz::Main.new
            end
            additemtolist("#{func_name}: #{pcap_filter}", "#{func_name};")
          end
        end
      }
      @bkm.instance_eval do
        definemenuitem("showfilter") do
          puts "Filter: #{@pcapsetfilter}"
        end
        additemtolist("Show Current Filter", "showfilter;")
      end
      @bkm.additemtolist("Display Menu", "showmenu;")
      @bkm.additemtolist("Toggle Menu", "togglemenu;")
      @bkm.additemtolist("Exit Trafviz", "exit;")
      @bkm.menu!
    end
        
    def load_filters(file)
      if File.exists?("#{Dir.home}/.thm/#{file}")
        read(file)
      else
        set_defaults(file)
        read(file)
      end
      build_filter_menu
    end
    
  end
  
end

# Main class / Startup

module Thm

  class DataServices::Trafviz::Main

    attr_accessor :startup
    
    def initialize
      @filter_const = Array.new
      @startup = String.new
      @thm = Thm::DataServices::Trafviz::FilterManager.new
    end

    def addfilter(const, filter)
      if @thm.validate_filter?(filter) == true
        filtercode = %Q{#{const} = Pcap::Filter.new('#{filter}', @trafviz.capture)}
        @filter_const << "#{const})"
        eval(filtercode)
      end
    end
    
    def commitfilters
      flts = @filter_const.join(" | ") # Build string of CONST names
      commitcode = %Q{@trafviz.add_filter(#{flts})}
      eval(flts)
    end
    
    def run!
      @trafviz = Pcaplet.new(@startup)
    end
  end

end

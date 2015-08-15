require 'pp'

module Thm

  class DataServices::Geolocation < DataServices
  
    attr_writer :geodebug
    
    def initialize
      @geodebug = false
      @continent_name, @country_name, @city_name = Array.new, Array.new, Array.new
    end
    
    def self.define_component(name)
      name_func = name.to_sym
      define_method(name_func) do |ip|
        geoquery = "SELECT count(*) as num FROM geoipdata_ipv4blocks_#{name_func} a "
        geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
        geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%';"
        begin
          res = @conn.query("#{geoquery}")
          rowgeocount = res.fetch_hash
          geocount = rowgeocount["num"].to_i
        rescue => e
          pp e
        end
        puts "Geo SELECT COUNT: #{geoquery}: Number: #{geocount}" if @geodebug == true
        if geocount > 0;
          geoquery = "SELECT continent_name, #{name_func}_name FROM geoipdata_ipv4blocks_#{name_func} a "
          geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
          geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.#{name_func}_name LIMIT 1;"
          puts "Geo SELECT: #{geoquery}" if @geodebug == true
          begin
            resgeo = @conn.query("#{geoquery}")
            while row = resgeo.fetch_hash do
              populategeo = instance_variable_get("@#{name_func}_name")
              populategeo << row["#{name_func}_name"].to_s
              instance_variable_set("@#{name_func}_name", populategeo)
              @continent_name = row["continent_name"].to_s
            end
          rescue => e
            pp e
          end
        else
          return false
        end
      end
    end

    define_component :country
    define_component :city

    def geoiplookup(ip)
      t = country(ip)
      city(ip)
      unless t == false
        res = "(#{@continent_name}) - \n"
        @country_name.each {|n|
          res << "[ #{n} ]"
        }
        @city_name.each {|n|
          res << "[ #{n} ] "
        }
        initialize
      else
        res = "Not Available"
      end
      return res
    end

  end

end

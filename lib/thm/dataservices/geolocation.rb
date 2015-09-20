########################################################################
#
# Author: Brian Hood
# Email: <brianh6854@googlemail.com>
# Description: Libraries - geolocation
#
#   Geo Data quick and simple
#
########################################################################

require 'pp'

module Thm

  class DataServices::Geolocation < DataServices
  
    attr_writer :geodebug
    
    def initialize
      @geodebug = false
      @continent_name, @country_name, @city_name = Array.new, Array.new, Array.new
    end
    
    def formatinet(ip, octets=2)
      if octets == 2
        "#{ip.split(".")[0]}.#{ip.split(".")[1]}"
      elsif octets == 3
        "#{ip.split(".")[0]}.#{ip.split(".")[1]}.#{ip.split(".")[2]}"
      end
    end
    
    def self.define_component(name)
      name_func = name.to_sym
      define_method(name_func) do |ip, geo|
        octets = formatinet(ip, 2)
        geoquery = "SELECT COUNT(*) as num FROM geoipdata_ipv4blocks_#{name_func} a "
        geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
        geoquery << "WHERE network LIKE '#{octets}.%';"
        begin
          res = @conn.query("#{geoquery}")
          rowgeocount = res.fetch_hash
          geocount = rowgeocount["num"].to_i
        rescue => e
          pp e
        end
        puts "Geo SELECT COUNT: #{geoquery}: Number: #{geocount}" if @geodebug == true
        if geocount > 0;
          geoquery = "SELECT "
          if geo == false
            geoquery << "continent_name, #{name_func}_name "
          else
            geoquery << "latitude, longitude "
          end
          geoquery << "FROM geoipdata_ipv4blocks_#{name_func} a "
          geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
          geoquery << "WHERE network LIKE '#{octets}.%' GROUP BY "
          if geo == false
            geoquery << "b.continent_name, b.#{name_func}_name "
          else
            geoquery << "a.latitude, a.longitude "
          end
          geoquery << "LIMIT 1;"
          puts "Geo SELECT: #{geoquery}" if @geodebug == true
          begin
            resgeo = @conn.query("#{geoquery}")
            while row = resgeo.fetch_hash do
              if geo == false
                populategeo = instance_variable_get("@#{name_func}_name")
                populategeo << row["#{name_func}_name"].to_s
                instance_variable_set("@#{name_func}_name", populategeo) # Only returns 1 row
                @continent_name = row["continent_name"].to_s
              else
                instance_variable_set("@latitude", row["latitude"].to_s)
                instance_variable_set("@longitude", row["longitude"].to_s)
              end
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

    # Geo set to false by default for normal operation
    def geoiplookup(ip, geo=false)
      t = country(ip, geo)
      city(ip, geo)
      unless t == false
        # Check if @longitude / @latitude exists for Reverse Geocoding options
        if instance_variable_defined?("@latitude") and instance_variable_defined?("@longitude")
          res = [@latitude, @longitude]
        else
          res = "(#{@continent_name}) - \n"
          @country_name.each {|n|
            res << "[ #{n} ]" unless n == ""
          }
          @city_name.each {|n|
            res << "[ #{n} ] " unless n == ""
          }
          initialize
        end
      else
        res = "Not Available"
      end
      return res
    end

  end

  class DataServices::Geocoding < DataServices
  
  end
  
end

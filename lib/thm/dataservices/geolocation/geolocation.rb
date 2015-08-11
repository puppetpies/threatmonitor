require 'pp'

module Thm

  class DataServices::Geolocation < DataServices
  
    attr_writer :geodebug
    
    def initialize
      @geodebug = false
      @continent_name = String.new
      @country_name = String.new
      @city_name = String.new
    end
    
    def self.define_component(name)
      name_func = name.to_sym
      define_method(name_func) do |ip|
        geoquery = "SELECT count(*) as num FROM geoipdata_ipv4blocks_#{name_func} a "
        geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
        geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.#{name_func}_name LIMIT 1;"
        res = @conn.query("#{geoquery}")
        rowgeocount = res.fetch_hash
        begin
          geocount = rowgeocount["num"]
        rescue => e
          pp e
        end
        puts "Geo SELECT COUNT: #{geoquery}: Number: #{geocount}" # if @geodebug == true
        if geocount > 0;
          geoquery = "SELECT continent_name, #{name_func}_name FROM geoipdata_ipv4blocks_#{name_func} a "
          geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
          geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.#{name_func}_name LIMIT 1;"
          puts "Geo SELECT: #{geoquery}" if @geodebug == true
          resgeo = @conn.query("#{geoquery}")
          row = resgeo.fetch_hash
          @continent_name = row["continent_name"].to_s
          instance_variable_set("@#{name_func}_name", row["#{name_func}_name"].to_s)
        else
          return false
        end
      end
    end

    define_component :country
    define_component :city
  
    def geoiplookup(ip)
      country(ip)
      city(ip)
      res = "( #{@country_name} - (#{@continent_name}) #{@city_name})"
      return res
    end

  end

end

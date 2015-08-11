module Thm

  class DataServices::Geolocation < DataServices
  
    attr_writer :geodebug
    
    def initialize
      @geodebug = false
    end
    
    def self.define_component(name)
      name_func = name.to_sym
      define_method(name_func) do 
        geoquery = "SELECT count(*) as num FROM geoipdata_ipv4blocks_#{name_func} a "
        geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
        geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.#{name_func}_name LIMIT 1;"
        res = @conn.query("#{geoquery}")
        row = res.fetch_hash
        num = row["num"].to_i
        if num == 0;
          return false
        else
          geoquery = "SELECT continent_name, #{name_func}_name FROM geoipdata_ipv4blocks_#{name_func} a "
          geoquery << "JOIN geoipdata_locations_#{name_func} b ON (a.geoname_id = b.geoname_id) "
          geoquery << "WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.#{name_func}_name LIMIT 1;"
        end
      end
    end

    define_component :country?
    define_component :city?
  
    def geoiplookup(ip)
      geoquery = country? | city?
      if @geodebug == true
        puts "Geo Query: #{geoquery}"
      end
      resusrcnt = @conn.query("#{geoquery}")
      while row = resusrcnt.fetch_hash do
        continent_name = row["continent_name"].to_s
        country_name = row["country_name"].to_s
        res = "(#{country_name})"
      end
      return res
    end

  end

end

module Thm

  class DataServices::Geolocation < DataServices
  
    attr_writer :geodebug
    
    def initialize
      @geodebug = false
    end

    def geoiplookup(ip)
      geoquery = "SELECT continent_name, country_name FROM geoipdata_ipv4blocks_country a JOIN geoipdata_locations_country b ON (a.geoname_id = b.geoname_id) WHERE network LIKE '#{ip.split(".")[0]}.#{ip.split(".")[1]}.%' GROUP BY b.continent_name, b.country_name LIMIT 1;"
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

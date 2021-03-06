-- http://dev.maxmind.com/geoip/geoip2/geolite2/

SET SCHEMA "threatmonitor";

DROP TABLE "threatmonitor".geoipdata_ipv4blocks_city;
CREATE TABLE "threatmonitor".geoipdata_ipv4blocks_city (
  network varchar(18),
  geoname_id char(10),
  registered_country_geoname_id char(30),
  represented_country_geoname_id char(30),
  is_anonymous_proxy char(30),
  is_satellite_provider char(30),
  postal_code char(30),
  latitude char(10),
  longitude char(10)
);

CREATE INDEX cindex_ipv4_network ON "threatmonitor".geoipdata_ipv4blocks_city(network);
CREATE INDEX cindex_ipv4_geoname_id ON "threatmonitor".geoipdata_ipv4blocks_city(geoname_id);
COPY 3037321 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_ipv4blocks_city FROM '/example_data/GeoLite2-City-CSV_20151103/GeoLite2-City-Blocks-IPv4.csv' USING DELIMITERS ',', '\n', '';


DROP TABLE "threatmonitor".geoipdata_locations_city;
CREATE TABLE "threatmonitor".geoipdata_locations_city (
  geoname_id char(10),
  locale_code char(2),
  continent_code char(2),
  continent_name char(15),
  country_iso_code char(2),
  country_name char(50),
  subdivision_1_iso_code char(70),
  subdivision_1_name char(50),
  subdivision_2_iso_code char(70),
  subdivision_2_name char(50),
  city_name char(70),
  metro_code char(30),
  time_zone char(30)
);

-- You need to do a replace on the file for Quotes cat filename.csv | sed -e 's/"//g' > outputfile.csv
CREATE INDEX cindex_country_geoname_id ON "threatmonitor".geoipdata_locations_city(geoname_id);
COPY 92781 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_locations_city FROM '/example_data/GeoLite2-City-CSV_20151103/GeoLite2-City-Locations-en.csv' USING DELIMITERS ',', '\n', '';


DROP TABLE "threatmonitor".geoipdata_ipv4blocks_country;
CREATE TABLE "threatmonitor".geoipdata_ipv4blocks_country (
  network varchar(18),
  geoname_id char(10),
  registered_country_geoname_id char(30),
  represented_country_geoname_id char(30),
  is_anonymous_proxy char(30),
  is_satellite_provider char(30)
);

CREATE INDEX index_ipv4_network ON "threatmonitor".geoipdata_ipv4blocks_country(network);
CREATE INDEX index_ipv4_geoname_id ON "threatmonitor".geoipdata_ipv4blocks_country(geoname_id);
COPY 180336 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_ipv4blocks_country FROM '/example_data/GeoLite2-Country-CSV_20151103/GeoLite2-Country-Blocks-IPv4.csv' USING DELIMITERS ',', '\n', '';

DROP TABLE "threatmonitor".geoipdata_locations_country;
CREATE TABLE "threatmonitor".geoipdata_locations_country (
  geoname_id char(10),
  locale_code char(2),
  continent_code char(2),
  continent_name char(15),
  country_iso_code char(2),
  country_name char(50)
-- FOREIGN KEY (geoname_id) REFERENCES "geoipdata".geoipdata_ipv4blocks_country (index_geoname_id)
);

-- Fix the second to last line with 7626844,en,NA,North America,BQ,Bonaire Sint Eustatius and Saba
CREATE INDEX index_country_geoname_id ON "threatmonitor".geoipdata_locations_country(geoname_id);
COPY 250 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_locations_country FROM '/example_data/GeoLite2-Country-CSV_20151103/GeoLite2-Country-Locations-en.csv' USING DELIMITERS ',', '\n', '';

plan SELECT continent_name, country_name 
FROM "threatmonitor".geoipdata_ipv4blocks_country a 
JOIN "threatmonitor".geoipdata_locations_country b
ON (a.geoname_id = b.geoname_id) 
JOIN "threatmonitor".ippacket c
ON (a.network = LEFT(c.ip_dst, 7))
WHERE network LIKE '216.58.208.%' 
GROUP BY b.continent_name, b.country_name
LIMIT 10;

SELECT ip_dst, network, continent_name, country_name 
FROM "threatmonitor".geoipdata_ipv4blocks_country a 
JOIN "threatmonitor".geoipdata_locations_country b
ON (a.geoname_id = b.geoname_id)
JOIN "threatmonitor".ippacket c
ON (a.network LIKE LEFT(c.ip_dst, 5))
WHERE network LIKE '216.58.%' 
GROUP BY b.continent_name, b.country_name, a.network, c.ip_dst
LIMIT 10;

-- SELECT network FROM "threatmonitor".geoipdata_ipv4blocks_country a JOIN WHERE network LIKE '23.%' LIMIT 5;
 
SELECT LEFT(network, 8) as net, locale_code, continent_code, continent_name, country_name, country_iso_code 
FROM "threatmonitor".geoipdata_ipv4blocks_country a 
JOIN "threatmonitor".geoipdata_locations_country b 
ON (a.geoname_id = b.geoname_id) 
JOIN "threatmonitor".ippacket c
ON (c.ip_dst LIKE LEFT(network, 8))
JOIN "threatmonitor".tcppacket d
ON (c.guid = d.guid)
WHERE network LIKE '23.%' 
GROUP BY a.network, b.locale_code, b.continent_code, b.continent_name, b.country_name, b.country_iso_code
LIMIT 100;



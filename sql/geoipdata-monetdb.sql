-- http://dev.maxmind.com/geoip/geoip2/geolite2/

-- id INT GENERATED ALWAYS AS 
--        IDENTITY (
--           START WITH 1 INCREMENT BY 1
--           NO MINVALUE NO MAXVALUE
--           CACHE 2 CYCLE
-- ) primary key,

DROP TABLE "threatmonitor".geoipdata_ipv4blocks_city;
CREATE TABLE "threatmonitor".geoipdata_ipv4blocks_city (
  network varchar(18) NOT NULL,
  geoname_id char(10) NOT NULL,
  registered_country_geoname_id char(30) NOT NULL,
  represented_country_geoname_id char(30) NOT NULL,
  is_anonymous_proxy char(30) NOT NULL,
  is_satellite_provider char(30) NOT NULL,
  postal_code char(30) NOT NULL,
  latitude char(10) NOT NULL,
  longitude char(10) NOT NULL
);

CREATE INDEX cindex_ipv4_network ON "threatmonitor".geoipdata_ipv4blocks_city(network);
CREATE INDEX cindex_ipv4_geoname_id ON "threatmonitor".geoipdata_ipv4blocks_city(geoname_id);
COPY 2519918 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_ipv4blocks_city FROM '/data2/MaxMind/GeoLite2-City-CSV_20150602/GeoLite2-City-Blocks-IPv4.csv' USING DELIMITERS ',', '\n', '';


DROP TABLE "threatmonitor".geoipdata_locations_city;
CREATE TABLE "threatmonitor".geoipdata_locations_city (
  geoname_id char(10) NOT NULL,
  locale_code char(2) NOT NULL,
  continent_code char(2) NOT NULL,
  continent_name char(15) NOT NULL,
  country_iso_code char(2) NOT NULL,
  country_name char(50) NOT NULL,
  subdivision_1_iso_code char(70) NOT NULL,
  subdivision_1_name char(50) NOT NULL,
  subdivision_2_iso_code char(70) NOT NULL,
  subdivision_2_name char(50) NOT NULL,
  city_name char(70) NOT NULL,
  metro_code char(30) NOT NULL,
  time_zone char(30) NOT NULL
);

CREATE INDEX cindex_country_geoname_id ON "threatmonitor".geoipdata_locations_city(geoname_id);
COPY 80006 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_locations_city FROM '/data2/MaxMind/GeoLite2-City-CSV_20150602/GeoLite2-City-Locations-en.csv' USING DELIMITERS ',', '\n', '';


DROP TABLE "threatmonitor".geoipdata_ipv4blocks_country;
CREATE TABLE "threatmonitor".geoipdata_ipv4blocks_country (
  network varchar(18) NOT NULL,
  geoname_id char(10) NOT NULL,
  registered_country_geoname_id char(30) NOT NULL,
  represented_country_geoname_id char(30) NOT NULL,
  is_anonymous_proxy char(30) NOT NULL,
  is_satellite_provider char(30) NOT NULL
);

CREATE INDEX index_ipv4_network ON "threatmonitor".geoipdata_ipv4blocks_country(network);
CREATE INDEX index_ipv4_geoname_id ON "threatmonitor".geoipdata_ipv4blocks_country(geoname_id);
COPY 169357 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_ipv4blocks_country FROM '/data2/MaxMind/GeoLite2-Country-CSV_20150602/GeoLite2-Country-Blocks-IPv4.csv' USING DELIMITERS ',', '\n', '';

DROP TABLE "threatmonitor".geoipdata_locations_country;
CREATE TABLE "threatmonitor".geoipdata_locations_country (
  geoname_id char(10) NOT NULL,
  locale_code char(2) NOT NULL,
  continent_code char(2) NOT NULL,
  continent_name char(15) NOT NULL,
  country_iso_code char(2) NOT NULL,
  country_name char(50) NOT NULL
-- FOREIGN KEY (geoname_id) REFERENCES "geoipdata".geoipdata_ipv4blocks_country (index_geoname_id)
);

CREATE INDEX index_country_geoname_id ON "threatmonitor".geoipdata_locations_country(geoname_id);
COPY 250 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_locations_country FROM '/data2/MaxMind/GeoLite2-Country-CSV_20150602/GeoLite2-Country-Locations-en.csv' USING DELIMITERS ',', '\n', '';

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
 
-- PLAN SELECT LEFT(network, 8) as net, locale_code, continent_code, continent_name, country_name, country_iso_code 
-- FROM "threatmonitor".geoipdata_ipv4blocks_country a 
-- JOIN "threatmonitor".geoipdata_locations_country b 
-- ON (a.geoname_id = b.geoname_id) 
-- JOIN "threatmonitor".wifi_ippacket c
-- ON (c.ip_dst LIKE LEFT(network, 8))
-- JOIN "threatmonitor".wifi_tcppacket d
-- ON (c.guid = d.guid)
-- WHERE network LIKE '23.%' 
-- GROUP BY a.network, b.locale_code, b.continent_code, b.continent_name, b.country_name, b.country_iso_code
-- LIMIT 100;



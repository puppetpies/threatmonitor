-- http://dev.maxmind.com/geoip/geoip2/geolite2/

-- id INT GENERATED ALWAYS AS 
--        IDENTITY (
--           START WITH 1 INCREMENT BY 1
--           NO MINVALUE NO MAXVALUE
--           CACHE 2 CYCLE
-- ) primary key,

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
COPY 169357 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_ipv4blocks_country FROM '/data2/MaxMind/GeoLite2-Country-CSV_20150602/GeoLite2-Country-Blocks-IPv4.csv' USING DELIMITERS ',', '\n', '';

DROP TABLE "threatmonitor".geoipdata_locations_country;
CREATE TABLE "threatmonitor".geoipdata_locations_country (
  geoname_id bigint not null,
  locale_code char(2),
  continent_code char(2),
  continent_name char(15),
  country_iso_code char(2),
  country_name char(50)
-- FOREIGN KEY (geoname_id) REFERENCES "geoipdata".geoipdata_ipv4blocks_country (index_geoname_id)
);

CREATE INDEX index_country_geoname_id ON "threatmonitor".geoipdata_locations_country(geoname_id);
COPY 250 OFFSET 2 RECORDS INTO "threatmonitor".geoipdata_locations_country FROM '/data2/MaxMind/GeoLite2-Country-CSV_20150602/GeoLite2-Country-Locations-en.csv' USING DELIMITERS ',', '\n', '';



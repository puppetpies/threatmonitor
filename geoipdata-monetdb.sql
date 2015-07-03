-- http://dev.maxmind.com/geoip/geoip2/geolite2/

CREATE SCHEMA "geoipdata";

DROP TABLE "geoipdata".ipv4blocks;
CREATE TABLE "geoipdata".ipv4blocks (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 1 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  network varchar(18),
  geoname_id int not null,
  registered_country_geoname_id int not null,
  represented_country_geoname_id int not null,
  is_anonymous_proxy char(1),
  is_satellite_provider char(1),
  UNIQUE (geoname_id)
);

DROP TABLE "geoipdata".locations;
CREATE TABLE "geoipdata".locations (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 1 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  geoname_id int not null,
  locale_code char(2),
  continent_code char(2),
  continent_name char(15),
  country_iso_code char(2),
  country_name char(50)
-- FOREIGN KEY (geoname_id) REFERENCES "geoipdata".ipv4blocks (geoname_id)
);

COPY 169357 OFFSET 1 RECORDS INTO "geoipdata".ipv4blocks FROM '/data2/MaxMind/GeoLite2-Country-Blocks-IPv4.csv' USING DELIMITERS ',','\n','';
COPY 250 OFFSET 1 RECORDS INTO "geoipdata".locations FROM '/data2/MaxMind/GeoLite2-Country-CSV_20150602/en.csv' USING DELIMITERS ',','\n','';



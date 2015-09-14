SET SCHEMA "threatmonitor";

DROP TABLE "threatmonitor".http_traffic_json;
CREATE TABLE "threatmonitor".http_traffic_json (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) PRIMARY KEY,
  guid CHAR(36) NOT NULL,
  recv_date DATE,
  recv_time TIME,
  json_data JSON
);

CREATE INDEX index_traffic_json_id ON "threatmonitor".http_traffic_json(id);
CREATE INDEX index_traffic_json_guid ON "threatmonitor".http_traffic_json(guid);

DROP TABLE "threatmonitor".http_traffic_ua;
CREATE TABLE "threatmonitor".http_traffic_ua (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) PRIMARY KEY,
  family VARCHAR(30),
  major CHAR(3) default 'NaN',
  minor CHAR(3) default 'NaN',
  os CHAR(20) NOT NULL,
  guid CHAR(36) NOT NULL
);

CREATE FUNCTION JSON_SQUASH(name string)
RETURNS string
BEGIN
  RETURN REPLACE(REPLACE(REPLACE(name, '[\"', ''), '\"]', ''), '"', '');
END;

/*
PLAN SELECT 
JSON_SQUASH(host) AS host, 
JSON_SQUASH(acceptlanguage) as acceptlanguage,
JSON_SQUASH(acceptencoding) as acceptencoding,
JSON_SQUASH(referer) as referer,
family,
major,
minor,
os
FROM 
(SELECT 
json.filter(json_data, '$.http.host') AS host,
json.filter(json_data, '$.http.acceptlanguage') AS acceptlanguage,
json.filter(json_data, '$.http.acceptencoding') AS acceptencoding,
json.filter(json_data, '$.http.referer') AS referer,
b.family,
b.major,
b.minor,
b.os
FROM http_traffic_json a JOIN http_traffic_ua b 
ON (a.guid = b.guid)) AS origin WHERE referer ILIKE '%http://%' LIMIT 30;
*/

/*
SELECT MIN(json_data) FROM http_traffic_json
*/

/*
Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0
*/

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

CREATE INDEX index_traffic_ua_id ON "threatmonitor".http_traffic_ua(id);
CREATE INDEX index_traffic_ua_guid ON "threatmonitor".http_traffic_ua(guid);

DROP FUNCTION JSON_SQUASH;
CREATE FUNCTION JSON_SQUASH(name string)
RETURNS string
BEGIN
  DECLARE res STRING;
  SET res = REPLACE(REPLACE(REPLACE(name, '[\"', ''), '\"]', ''), '"', '');
  IF (res = '[]') THEN
    SET res = REPLACE(res, '[]', '<no data>');
  END IF;
  RETURN res;
END;

CREATE VIEW traffic_view_5mins AS (SELECT
recv_date,
recv_time,
JSON_SQUASH(host) AS host, 
JSON_SQUASH(acceptlanguage) AS acceptlanguage,
JSON_SQUASH(referer) AS referer,
family,
major,
minor,
os
FROM 
(SELECT
a.recv_date AS recv_date,
a.recv_time AS recv_time,
json.filter(json_data, '$.http.host') AS host,
json.filter(json_data, '$.http.acceptlanguage') AS acceptlanguage,
json.filter(json_data, '$.http.acceptencoding') AS acceptencoding,
json.filter(json_data, '$.http.referer') AS referer,
b.family,
b.major,
b.minor,
b.os
FROM http_traffic_json a JOIN http_traffic_ua b 
ON (a.guid = b.guid)) AS origin WHERE recv_time BETWEEN CURTIME() - 300 AND CURTIME());

CREATE VIEW traffic_view_15mins AS (SELECT
recv_date,
recv_time,
JSON_SQUASH(host) AS host, 
JSON_SQUASH(acceptlanguage) AS acceptlanguage,
JSON_SQUASH(referer) AS referer,
family,
major,
minor,
os
FROM 
(SELECT
a.recv_date AS recv_date,
a.recv_time AS recv_time,
json.filter(json_data, '$.http.host') AS host,
json.filter(json_data, '$.http.acceptlanguage') AS acceptlanguage,
json.filter(json_data, '$.http.acceptencoding') AS acceptencoding,
json.filter(json_data, '$.http.referer') AS referer,
b.family,
b.major,
b.minor,
b.os
FROM http_traffic_json a JOIN http_traffic_ua b 
ON (a.guid = b.guid)) AS origin WHERE recv_time BETWEEN CURTIME() - 900 AND CURTIME());

CREATE VIEW traffic_view_30mins AS (SELECT
recv_date,
recv_time,
JSON_SQUASH(host) AS host, 
JSON_SQUASH(acceptlanguage) AS acceptlanguage,
JSON_SQUASH(referer) AS referer,
family,
major,
minor,
os
FROM 
(SELECT
a.recv_date AS recv_date,
a.recv_time AS recv_time,
json.filter(json_data, '$.http.host') AS host,
json.filter(json_data, '$.http.acceptlanguage') AS acceptlanguage,
json.filter(json_data, '$.http.acceptencoding') AS acceptencoding,
json.filter(json_data, '$.http.referer') AS referer,
b.family,
b.major,
b.minor,
b.os
FROM http_traffic_json a JOIN http_traffic_ua b 
ON (a.guid = b.guid)) AS origin WHERE recv_time BETWEEN CURTIME() - 1800 AND CURTIME());
/*
SELECT MIN(json_data) FROM http_traffic_json
*/

/*
Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.0
*/

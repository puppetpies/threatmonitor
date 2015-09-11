
DROP TABLE "threatmonitor".http_traffic_json;
CREATE TABLE "threatmonitor".http_traffic_json (
id INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 0 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) PRIMARY KEY,
  guid CHAR(36),
  recv_date DATE,
  recv_time TIME,
  json_data JSON
);

CREATE FUNCTION JSON_SQUASH(name string)
RETURNS string
BEGIN
  RETURN REPLACE(REPLACE(REPLACE(name, '[\"', ''), '\"]', ''), '"', '');
END;

/*
SELECT JSON_SQUASH(host) AS host, 
JSON_SQUASH(referer) AS referer 
FROM 
(SELECT 
json.filter(json_data, '$.http.host') AS host, 
json.filter(json_data, '$.http.referer') AS referer 
FROM http_traffic_json) AS origin
LIMIT 10;
*/

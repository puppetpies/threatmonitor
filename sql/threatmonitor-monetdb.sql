
CREATE USER "threatmonitor" WITH PASSWORD 'dk3rbi9l' NAME 'Threatmonitor' SCHEMA "sys";
CREATE SCHEMA "threatmonitor" AUTHORIZATION "threatmonitor";
ALTER USER "threatmonitor" SET SCHEMA "threatmonitor";

DROP TABLE "threatmonitor".ippacket;
CREATE TABLE "threatmonitor".ippacket (
  "guid" char(36) not null primary key,
  "recv_date" string,
  "ip_df" varchar(5),
  "ip_dst" varchar(15),
  "ip_hlen" int not null,
  "ip_id" int not null,
  "ip_len" int not null,
  "ip_mf" varchar(5),
  "ip_off" int not null,
  "ip_proto" int not null,
  "ip_src" varchar(15),
  "ip_sum" char(10),
  "ip_tos" int not null,
  "ip_ttl" int not null,
  "ip_ver" int not null 
);
CREATE INDEX index_guid_defaultip ON "threatmonitor".ippacket(guid);
CREATE INDEX index_ip_dst_defaultip ON "threatmonitor".ippacket(ip_dst);
CREATE INDEX index_ip_src_defaultip ON "threatmonitor".ippacket(ip_src);

DROP TABLE "threatmonitor".tcppacket;
CREATE TABLE "threatmonitor".tcppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "tcp_data_len" int DEFAULT NULL,
  "tcp_dport" int DEFAULT NULL,
  "tcp_ack" char(1) DEFAULT NULL,
  "tcp_fin" char(1) DEFAULT NULL,
  "tcp_syn" char(1)DEFAULT NULL,
  "tcp_rst" char(1) DEFAULT NULL,
  "tcp_psh" char(1) DEFAULT NULL,
  "tcp_urg" char(1) DEFAULT NULL,
  "tcp_off" int DEFAULT NULL,
  "tcp_hlen" int DEFAULT NULL,
  "tcp_seq" bigint DEFAULT NULL,
  "tcp_sum" char(10) DEFAULT NULL,
  "tcp_sport" int DEFAULT NULL,
  "tcp_urp" char(10) DEFAULT NULL,
  "tcp_win" int DEFAULT NULL
);
CREATE INDEX index_guid_defaulttcp ON "threatmonitor".tcppacket(guid);
CREATE INDEX index_tcp_dport_defaulttcp ON "threatmonitor".tcppacket(tcp_dport);
CREATE INDEX index_tcp_sport_defaulttcp ON "threatmonitor".tcppacket(tcp_sport);


DROP TABLE "threatmonitor".udppacket;
CREATE TABLE "threatmonitor".udppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);
CREATE INDEX index_guid_defaultudp ON "threatmonitor".udppacket(guid);
CREATE INDEX index_udp_dport_defaultudp ON "threatmonitor".udppacket(udp_dport);
CREATE INDEX index_udp_sport_defaultudp ON "threatmonitor".udppacket(udp_sport);

# Wifi
DROP TABLE "threatmonitor".wifi_ippacket;
CREATE TABLE "threatmonitor".wifi_ippacket (
  "guid" char(36) not null primary key,
  "recv_date" string,
  "ip_df" varchar(5),
  "ip_dst" varchar(15),
  "ip_hlen" int not null,
  "ip_id" int not null,
  "ip_len" int not null,
  "ip_mf" varchar(5),
  "ip_off" int not null,
  "ip_proto" int not null,
  "ip_src" varchar(15),
  "ip_sum" char(10),
  "ip_tos" int not null,
  "ip_ttl" int not null,
  "ip_ver" int not null 
);

CREATE INDEX index_guid_wifiip ON "threatmonitor".wifi_ippacket(guid);
CREATE INDEX index_ip_dst_wifiip ON "threatmonitor".wifi_ippacket(ip_dst);
CREATE INDEX index_ip_src_wifiip ON "threatmonitor".wifi_ippacket(ip_src);

DROP TABLE "threatmonitor".wifi_tcppacket;
CREATE TABLE "threatmonitor".wifi_tcppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "tcp_data_len" int DEFAULT NULL,
  "tcp_dport" int DEFAULT NULL,
  "tcp_ack" char(1) DEFAULT NULL,
  "tcp_fin" char(1) DEFAULT NULL,
  "tcp_syn" char(1)DEFAULT NULL,
  "tcp_rst" char(1) DEFAULT NULL,
  "tcp_psh" char(1) DEFAULT NULL,
  "tcp_urg" char(1) DEFAULT NULL,
  "tcp_off" int DEFAULT NULL,
  "tcp_hlen" int DEFAULT NULL,
  "tcp_seq" bigint DEFAULT NULL,
  "tcp_sum" char(10) DEFAULT NULL,
  "tcp_sport" int DEFAULT NULL,
  "tcp_urp" char(10) DEFAULT NULL,
  "tcp_win" int DEFAULT NULL
);
CREATE INDEX index_guid_wifitcp ON "threatmonitor".wifi_tcppacket(guid);
CREATE INDEX index_tcp_dport_wifitcp ON "threatmonitor".wifi_tcppacket(tcp_dport);
CREATE INDEX index_tcp_sport_wifitcp ON "threatmonitor".wifi_tcppacket(tcp_sport);


DROP TABLE "threatmonitor".wifi_udppacket;
CREATE TABLE "threatmonitor".wifi_udppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);

CREATE INDEX index_guid_wifiudp ON "threatmonitor".wifi_udppacket(guid);
CREATE INDEX index_udp_dport_wifiudp ON "threatmonitor".wifi_udppacket(udp_dport);
CREATE INDEX index_udp_sport_wifiudp ON "threatmonitor".wifi_udppacket(udp_sport);

CREATE TABLE "threatmonitor".groups (
gid INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 100 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  groupname varchar(100) not null
);

CREATE TABLE "threatmonitor".users (
uid INT GENERATED ALWAYS AS 
        IDENTITY (
           START WITH 100 INCREMENT BY 1
           NO MINVALUE NO MAXVALUE
           CACHE 2 CYCLE
) primary key,
  username varchar(100) not null,
  password varchar(512),
  gid int not null,
  FOREIGN KEY (gid) REFERENCES "threatmonitor".groups (gid)
);

CREATE TABLE "threatmonitor".service_definitions (
  protocol char(5),
  num int not null,
  description char(30)
);

# Query not working due lack of aggregate function

#select "ip_dst", "tcp_sport", "tcp_dport", count("ip_dst") as num from tcppacket sel LEFT JOIN ippacket sel2 ON (sel2.guid = sel.guid) GROUP by "ip_dst";

# Service / Ports / IP
select * from wifi_ippacket a JOIN wifi_udppacket b on (a.guid = b.guid) JOIN service_definitions s on (s.num = b.udp_dport) where udp_dport > 0 and udp_dport < 10000 and s.protocol = 'UDP' group by b.udp_dport, a.ip_dst, s.description;

#COPY INTO threatmonitor.ippacket from '/tmp/ippacket.csv' USING DELIMITERS '|','\n', '"';
#COPY INTO threatmonitor.tcppacket from '/tmp/tcppacket.csv' USING DELIMITERS '|','\n', '"';
#COPY INTO threatmonitor.udppacket from '/tmp/udppacket.csv' USING DELIMITERS '|','\n', '"';

COPY INTO "threatmonitor".service_definitions FROM '/home/brian/Projects/ThreatmonitorDashboard/tcpudpportslist.csv' DELIMITERS ',';

#INSERT INTO "threatmonitor".wifi_tcppacket 
#(guid, recv_date, tcp_data_len, tcp_dport, tcp_ack, tcp_fin, tcp_syn, tcp_rst, tcp_psh, tcp_urg, tcp_off, tcp_hlen, tcp_seq, tcp_sum, tcp_sport, tcp_urp, tcp_win) 
#VALUES ('a6cd6b9f-53cf-a1db-f4f5-644e118394f0','2015-06-20 14:46:33 +0100', '1448','51213','N','N','N','N','N','N','8', '8', '3248172952', '55697', '80', '0', '239');


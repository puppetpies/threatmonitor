
CREATE USER "threatmonitor" WITH PASSWORD 'dk3rbi9l' NAME 'Threatmonitor' SCHEMA "sys";
CREATE SCHEMA "threatmonitor" AUTHORIZATION "threatmonitor";
ALTER USER "threatmonitor" SET SCHEMA "threatmonitor";

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
  "tcp_seq" int DEFAULT NULL,
  "tcp_sum" char(10) DEFAULT NULL,
  "tcp_sport" int DEFAULT NULL,
  "tcp_urp" char(10) DEFAULT NULL,
  "tcp_win" int DEFAULT NULL
);


CREATE TABLE "threatmonitor".udppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);


# Wifi

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


CREATE TABLE "threatmonitor".wifi_udppacket (
  "guid" char(36) NOT NULL primary key,
  "recv_date" string,
  "udp_dport" int,
  "udp_len" int,
  "udp_sum" char(10) DEFAULT NULL,
  "udp_sport" int DEFAULT NULL
);


# Query not working due lack of aggregate function

#select "ip_dst", "tcp_sport", "tcp_dport", count("ip_dst") as num from tcppacket sel LEFT JOIN ippacket sel2 ON (sel2.guid = sel.guid) GROUP by "ip_dst";

#COPY INTO threatmonitor.ippacket from '/tmp/ippacket.csv' USING DELIMITERS '|','\n', '"';
#COPY INTO threatmonitor.tcppacket from '/tmp/tcppacket.csv' USING DELIMITERS '|','\n', '"';
#COPY INTO threatmonitor.udppacket from '/tmp/udppacket.csv' USING DELIMITERS '|','\n', '"';


INSERT INTO "threatmonitor".wifi_tcppacket 
(guid, recv_date, tcp_data_len, tcp_dport, tcp_ack, tcp_fin, tcp_syn, tcp_rst, tcp_psh, tcp_urg, tcp_off, tcp_hlen, tcp_seq, tcp_sum, tcp_sport, tcp_urp, tcp_win) 
VALUES ('a6cd6b9f-53cf-a1db-f4f5-644e118394f0','2015-06-20 14:46:33 +0100', '1448','51213','N','N','N','N','N','N','8', '8', '3248172952', '55697', '80', '0', '239');


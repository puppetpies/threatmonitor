
DROP TABLE IF EXISTS `ippacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ippacket` (
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
  "ip_ver" int not null,
  PRIMARY KEY (`guid`) 
) ENGINE=INNODB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `tcppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tcppacket` (
  `guid` char(36) NOT NULL DEFAULT '',
  `recv_date` date DEFAULT NULL,
  `tcp_data` blob,
  `tcp_data_len` int(10) DEFAULT NULL,
  `tcp_dport` int(5) DEFAULT NULL,
  `tcp_ack` enum('Y','N') DEFAULT NULL,
  `tcp_fin` enum('Y','N') DEFAULT NULL,
  `tcp_syn` enum('Y','N') DEFAULT NULL,
  `tcp_rst` enum('Y','N') DEFAULT NULL,
  `tcp_psh` enum('Y','N') DEFAULT NULL,
  `tcp_urg` enum('Y','N') DEFAULT NULL,
  `tcp_off` int(10) DEFAULT NULL,
  `tcp_hlen` int(10) DEFAULT NULL,
  `tcp_seq` bigint(10) DEFAULT NULL,
  `tcp_sum` char(10) DEFAULT NULL,
  `tcp_sport` int(5) DEFAULT NULL,
  `tcp_urp` char(10) DEFAULT NULL,
  `tcp_win` int(10) DEFAULT NULL,
  PRIMARY KEY (`guid`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `udppacket`
--

DROP TABLE IF EXISTS `udppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `udppacket` (
  `guid` char(36) NOT NULL DEFAULT '',
  `recv_date` date DEFAULT NULL,
  `udp_data` blob,
  `udp_dport` int(5) DEFAULT NULL,
  `udp_len` int(10) DEFAULT NULL,
  `udp_sum` char(10) DEFAULT NULL,
  `udp_sport` int(5) DEFAULT NULL,
  PRIMARY KEY (`guid`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;

# Wifi

DROP TABLE IF EXISTS `wifi_ippacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wifi_ippacket` (
  `guid` char(36) not null default '',
  `recv_date` date DEFAULT NULL,
  `ip_df` varchar(5),
  `ip_dst` varchar(15),
  `ip_hlen` int not null,
  `ip_id` int not null,
  `ip_len` int not null,
  `ip_mf` varchar(5),
  `ip_off` int not null,
  `ip_proto` int not null,
  `ip_src` varchar(15),
  `ip_sum` char(10),
  `ip_tos` int not null,
  `ip_ttl` int not null,
  `ip_ver` int not null,
  PRIMARY KEY (`guid`) 
) ENGINE=INNODB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `wifi_tcppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wifi_tcppacket` (
  `guid` char(36) NOT NULL DEFAULT '',
  `recv_date` date DEFAULT NULL,
  `tcp_data` blob,
  `tcp_data_len` int(10) DEFAULT NULL,
  `tcp_dport` int(5) DEFAULT NULL,
  `tcp_ack` enum('Y','N') DEFAULT NULL,
  `tcp_fin` enum('Y','N') DEFAULT NULL,
  `tcp_syn` enum('Y','N') DEFAULT NULL,
  `tcp_rst` enum('Y','N') DEFAULT NULL,
  `tcp_psh` enum('Y','N') DEFAULT NULL,
  `tcp_urg` enum('Y','N') DEFAULT NULL,
  `tcp_off` int(10) DEFAULT NULL,
  `tcp_hlen` int(10) DEFAULT NULL,
  `tcp_seq` bigint(10) DEFAULT NULL,
  `tcp_sum` char(10) DEFAULT NULL,
  `tcp_sport` int(5) DEFAULT NULL,
  `tcp_urp` char(10) DEFAULT NULL,
  `tcp_win` int(10) DEFAULT NULL,
  PRIMARY KEY (`guid`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `udppacket`
--

DROP TABLE IF EXISTS `wifi_udppacket`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wifi_udppacket` (
  `guid` char(36) NOT NULL DEFAULT '',
  `recv_date` date DEFAULT NULL,
  `udp_data` blob,
  `udp_dport` int(5) DEFAULT NULL,
  `udp_len` int(10) DEFAULT NULL,
  `udp_sum` char(10) DEFAULT NULL,
  `udp_sport` int(5) DEFAULT NULL,
  PRIMARY KEY (`guid`)
) ENGINE=INNODB DEFAULT CHARSET=latin1;

-- CHANGE MASTER TO MASTER_HOST=’dev-vnc-01′,
-- MASTER_PORT=3306,
-- MASTER_USER=’orinoco’,
-- MASTER_PASSWORD=’wimbledon';


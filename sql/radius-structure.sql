-- MySQL dump 10.13  Distrib 5.1.73, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: radius
-- ------------------------------------------------------
-- Server version	5.1.73-1-log

SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT ;
SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS ;
SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION ;
SET NAMES utf8 ;
SET @OLD_TIME_ZONE=@@TIME_ZONE ;
SET TIME_ZONE='+00:00' ;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 ;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 ;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' ;
SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 ;

--
-- Table structure for table `badusers`
--
DROP DATABASE IF EXISTS `radius`;
CREATE DATABASE `radius`;

USE `radius`;

DROP TABLE IF EXISTS `badusers`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `badusers` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(30) DEFAULT NULL,
  `Date` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `Reason` varchar(200) DEFAULT NULL,
  `Admin` varchar(30) DEFAULT '-',
  PRIMARY KEY (`id`),
  KEY `UserName` (`UserName`),
  KEY `Date` (`Date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Temporary table structure for view `datausage`
--

DROP TABLE IF EXISTS `datausage`;
DROP VIEW IF EXISTS `datausage`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE TABLE `datausage` (
 `totaldata` tinyint NOT NULL,
  `YEAR` tinyint NOT NULL,
  `MONTH` tinyint NOT NULL,
  `DAY` tinyint NOT NULL,
  `username` tinyint NOT NULL,
  `realm` tinyint NOT NULL
) ENGINE=InnoDB */;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `mtotacct`
--

DROP TABLE IF EXISTS `mtotacct`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `mtotacct` (
  `MTotAcctId` bigint(21) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(64) NOT NULL DEFAULT '',
  `AcctDate` date NOT NULL DEFAULT '0000-00-00',
  `ConnNum` bigint(12) DEFAULT NULL,
  `ConnTotDuration` bigint(12) DEFAULT NULL,
  `ConnMaxDuration` bigint(12) DEFAULT NULL,
  `ConnMinDuration` bigint(12) DEFAULT NULL,
  `InputOctets` bigint(12) DEFAULT NULL,
  `OutputOctets` bigint(12) DEFAULT NULL,
  `NASIPAddress` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`MTotAcctId`),
  KEY `UserName` (`UserName`),
  KEY `AcctDate` (`AcctDate`),
  KEY `UserOnDate` (`UserName`,`AcctDate`),
  KEY `NASIPAddress` (`NASIPAddress`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `nas`
--

DROP TABLE IF EXISTS `nas`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `nas` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `nasname` varchar(128) NOT NULL,
  `shortname` varchar(32) DEFAULT NULL,
  `type` varchar(30) DEFAULT 'other',
  `ports` int(5) DEFAULT NULL,
  `secret` varchar(60) NOT NULL DEFAULT 'secret',
  `community` varchar(50) DEFAULT NULL,
  `description` varchar(200) DEFAULT 'RADIUS Client',
  `server` varchar(128) NULL,
  PRIMARY KEY (`id`),
  KEY `nasname` (`nasname`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radacct`
--

DROP TABLE IF EXISTS `radacct`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radacct` (
  `radacctid` bigint(21) NOT NULL AUTO_INCREMENT,
  `acctsessionid` varchar(64) NOT NULL DEFAULT '',
  `acctuniqueid` varchar(32) NOT NULL DEFAULT '',
  `UserName` varchar(64) NOT NULL DEFAULT '',
  `GroupName` varchar(64) NOT NULL DEFAULT '',
  `realm` varchar(64) DEFAULT '',
  `NASIPAddress` varchar(15) NOT NULL DEFAULT '',
  `NASPortId` varchar(15) DEFAULT NULL,
  `nasporttype` varchar(32) DEFAULT NULL,
  `AcctStartTime` datetime DEFAULT NULL,
  `AcctStopTime` datetime DEFAULT NULL,
  `AcctSessionTime` int(12) DEFAULT NULL,
  `acctauthentic` varchar(32) DEFAULT NULL,
  `connectinfo_start` varchar(50) DEFAULT NULL,
  `connectinfo_stop` varchar(50) DEFAULT NULL,
  `AcctInputOctets` bigint(20) DEFAULT NULL,
  `AcctOutputOctets` bigint(20) DEFAULT NULL,
  `CalledStationId` varchar(50) NOT NULL DEFAULT '',
  `CallingStationId` varchar(50) NOT NULL DEFAULT '',
  `acctterminatecause` varchar(32) NOT NULL DEFAULT '',
  `servicetype` varchar(32) DEFAULT NULL,
  `framedprotocol` varchar(32) DEFAULT NULL,
  `FramedIPAddress` varchar(15) NOT NULL DEFAULT '',
  `acctstartdelay` int(12) DEFAULT NULL,
  `acctstopdelay` int(12) DEFAULT NULL,
  `xascendsessionsvrkey` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`radacctid`),
  KEY `username` (`UserName`),
  KEY `framedipaddress` (`FramedIPAddress`),
  KEY `acctsessionid` (`acctsessionid`),
  KEY `acctsessiontime` (`AcctSessionTime`),
  KEY `acctuniqueid` (`acctuniqueid`),
  KEY `acctstarttime` (`AcctStartTime`),
  KEY `acctstoptime` (`AcctStopTime`),
  KEY `nasipaddress` (`NASIPAddress`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;
SET @saved_cs_client      = @@character_set_client  ;
SET @saved_cs_results     = @@character_set_results  ;
SET @saved_col_connection = @@collation_connection  ;
SET character_set_client  = latin1  ;
SET character_set_results = latin1  ;
SET collation_connection  = latin1_swedish_ci  ;
SET @saved_sql_mode       = @@sql_mode  ;
SET sql_mode              = ''  ;
DELIMITER ;;
CREATE TRIGGER radacct_after_update
    AFTER update ON radacct FOR EACH ROW BEGIN
    IF @disable_triggers IS NULL THEN
      INSERT INTO user_stats 
        SET 
        radacct_id = OLD.radacctid, 
        username = OLD.username,
        acctsessionid=OLD.acctsessionid,
        acctuniqueid = OLD.acctuniqueid,
        acctinputoctets = (NEW.acctinputoctets - OLD.acctinputoctets), 
        acctoutputoctets = (NEW.acctoutputoctets - OLD.acctoutputoctets);
    END IF;
END ;;
DELIMITER ;
SET sql_mode              = @saved_sql_mode  ;
SET character_set_client  = @saved_cs_client  ;
SET character_set_results = @saved_cs_results  ;
SET collation_connection  = @saved_col_connection  ;

--
-- Table structure for table `radcheck`
--

DROP TABLE IF EXISTS `radcheck`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radcheck` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL DEFAULT '',
  `attribute` varchar(32) NOT NULL DEFAULT '',
  `op` char(2) NOT NULL DEFAULT '==',
  `value` varchar(253) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `username` (`username`(32))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radgroupcheck`
--

DROP TABLE IF EXISTS `radgroupcheck`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radgroupcheck` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `groupname` varchar(64) NOT NULL DEFAULT '',
  `attribute` varchar(32) NOT NULL DEFAULT '',
  `op` char(2) NOT NULL DEFAULT '==',
  `value` varchar(253) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `groupname` (`groupname`(32))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radgroupreply`
--

DROP TABLE IF EXISTS `radgroupreply`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radgroupreply` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `groupname` varchar(64) NOT NULL DEFAULT '',
  `attribute` varchar(32) NOT NULL DEFAULT '',
  `op` char(2) NOT NULL DEFAULT '=',
  `value` varchar(253) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `groupname` (`groupname`(32))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radippool`
--

DROP TABLE IF EXISTS `radippool`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radippool` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `pool_name` varchar(30) NOT NULL,
  `framedipaddress` varchar(15) NOT NULL DEFAULT '',
  `nasipaddress` varchar(15) NOT NULL DEFAULT '',
  `calledstationid` varchar(30) NOT NULL,
  `callingstationid` varchar(30) NOT NULL,
  `expiry_time` datetime DEFAULT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `pool_key` varchar(30) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radpostauth`
--

DROP TABLE IF EXISTS `radpostauth`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radpostauth` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL DEFAULT '',
  `pass` varchar(64) NOT NULL DEFAULT '',
  `reply` varchar(32) NOT NULL DEFAULT '',
  `authdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radreply`
--

DROP TABLE IF EXISTS `radreply`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radreply` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(64) NOT NULL DEFAULT '',
  `attribute` varchar(32) NOT NULL DEFAULT '',
  `op` char(2) NOT NULL DEFAULT '=',
  `value` varchar(253) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `username` (`username`(32))
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `radusergroup`
--

DROP TABLE IF EXISTS `radusergroup`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `radusergroup` (
  `username` varchar(64) NOT NULL DEFAULT '',
  `groupname` varchar(64) NOT NULL DEFAULT '',
  `priority` int(11) NOT NULL DEFAULT '1',
  KEY `username` (`username`(32))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `totacct`
--

DROP TABLE IF EXISTS `totacct`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `totacct` (
  `TotAcctId` bigint(21) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(64) NOT NULL DEFAULT '',
  `AcctDate` date NOT NULL DEFAULT '0000-00-00',
  `ConnNum` bigint(12) DEFAULT NULL,
  `ConnTotDuration` bigint(12) DEFAULT NULL,
  `ConnMaxDuration` bigint(12) DEFAULT NULL,
  `ConnMinDuration` bigint(12) DEFAULT NULL,
  `InputOctets` bigint(12) DEFAULT NULL,
  `OutputOctets` bigint(12) DEFAULT NULL,
  `NASIPAddress` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`TotAcctId`),
  KEY `UserName` (`UserName`),
  KEY `AcctDate` (`AcctDate`),
  KEY `UserOnDate` (`UserName`,`AcctDate`),
  KEY `NASIPAddress` (`NASIPAddress`),
  KEY `NASIPAddressOnDate` (`AcctDate`,`NASIPAddress`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `user_billing_detail`
--

DROP TABLE IF EXISTS `user_billing_detail`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `user_billing_detail` ( 
  `username` varchar(255) NOT NULL,
  `anniversary_day` int(11) NOT NULL,
  `action` enum('shape','excess') NOT NULL,
  `status` enum('normal','warning','violating') NOT NULL DEFAULT 'normal',
  PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `user_data`
--

DROP TABLE IF EXISTS `user_data`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `user_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) NOT NULL,
  `datain` bigint(20) NOT NULL,
  `dataout` bigint(20) NOT NULL,
  `totaldata` bigint(20) NOT NULL,
  `data_hour` int(11) NOT NULL,
  `date` date NOT NULL,
  PRIMARY KEY(`id`),
  UNIQUE KEY `user_date_index` (`username`,`data_hour`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `user_quota`
--

DROP TABLE IF EXISTS `user_quota`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `user_quota` (
  `username` varchar(255) NOT NULL,
  `quota_date` datetime NOT NULL,
  `quota` bigint(255) NOT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `user_stats`
--

DROP TABLE IF EXISTS `user_stats`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `user_stats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `radacct_id` int(11) NOT NULL,
  `username` varchar(64) NOT NULL,
  `acctsessionid` varchar(64) NOT NULL,
  `acctuniqueid` varchar(32) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `acctinputoctets` bigint(20) NOT NULL,
  `acctoutputoctets` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=latin1;
SET character_set_client = @saved_cs_client ;

--
-- Table structure for table `userinfo`
--

DROP TABLE IF EXISTS `userinfo`;
SET @saved_cs_client     = @@character_set_client ;
SET character_set_client = utf8 ;
CREATE TABLE `userinfo` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `UserName` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Name` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Mail` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Department` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `WorkPhone` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `HomePhone` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `Mobile` varchar(200) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UserName` (`UserName`),
  KEY `Departmet` (`Department`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
SET character_set_client = @saved_cs_client ;

--
-- Final view structure for view `datausage`
--

DROP TABLE IF EXISTS `datausage`;
DROP VIEW IF EXISTS `datausage`;
SET @saved_cs_client          = @@character_set_client ;
SET @saved_cs_results         = @@character_set_results ;
SET @saved_col_connection     = @@collation_connection ;
SET character_set_client      = utf8 ;
SET character_set_results     = utf8 ;
SET collation_connection      = utf8_general_ci ;
CREATE ALGORITHM=UNDEFINED 
DEFINER=`root`@`localhost` SQL SECURITY DEFINER 
VIEW `datausage` AS select (((sum(`user_data`.`totaldata`) / 1024) / 1024) / 1024) AS `totaldata`,year(`user_data`.`date`) AS `YEAR`,month(`user_data`.`date`) AS `MONTH`,dayofmonth(`user_data`.`date`) AS `DAY`,`user_data`.`username` AS `username`,substring_index(`user_data`.`username`,'@',-(1)) AS `realm` from `user_data` group by `user_data`.`username`,year(`user_data`.`date`),month(`user_data`.`date`),dayofmonth(`user_data`.`date`) order by year(`user_data`.`date`),month(`user_data`.`date`),(((sum(`user_data`.`totaldata`) / 1024) / 1024) / 1024) desc ;
SET character_set_client      = @saved_cs_client ;
SET character_set_results     = @saved_cs_results ;
SET collation_connection      = @saved_col_connection ;
SET TIME_ZONE=@OLD_TIME_ZONE ;

SET SQL_MODE=@OLD_SQL_MODE ;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS ;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS ;
SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT ;
SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS ;
SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION ;
SET SQL_NOTES=@OLD_SQL_NOTES ;

GRANT ALL PRIVILEGES ON radius.* to 'radius'@'%' identified by 'radius';
INSERT into `nas`
    (`id`, `nasname`, `shortname`, `type`, `ports`, `secret`, `community`, `description`, `server`)
  VALUES
  (NULL, "0.0.0.0/0", "catchall", "other", "1812", "password", "public", "default", "sql");


-- Dump completed on 2015-11-08 14:37:53

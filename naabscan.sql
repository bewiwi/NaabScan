-- phpMyAdmin SQL Dump
-- version 3.4.10.1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le : Ven 14 Juin 2013 à 17:54
-- Version du serveur: 5.1.66
-- Version de PHP: 5.3.3-7+squeeze15

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `naabscan`
--

-- --------------------------------------------------------

--
-- Structure de la table `host`
--

CREATE TABLE IF NOT EXISTS `host` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `ip` varchar(16) NOT NULL,
      `scan` int(1),
      PRIMARY KEY (`id`),
      UNIQUE KEY `ip` (`ip`)
    ) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=66 ;

    -- --------------------------------------------------------

--
-- Structure de la table `port`
--

CREATE TABLE IF NOT EXISTS `port` (
      `scan_id` int(255) DEFAULT NULL,
      `protocol` text,
      `number` int(6),
      `state` text,
      `service_name` text,
      `service_product` text,
      `service_version` text,
      `service_extra` text,
      `service_ostype` text,
      `script_info` text
    ) ENGINE=MyISAM DEFAULT CHARSET=latin1;

    -- --------------------------------------------------------

--
-- Structure de la table `scan`
--

CREATE TABLE IF NOT EXISTS `scan` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `date` int(12) NOT NULL,
      `host_id` int(11) NOT NULL,
      PRIMARY KEY (`id`)
    ) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=67 ;

    /*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

ALTER TABLE scan Add country text;
ALTER TABLE scan Add latitude float;
ALTER TABLE scan Add longitude float;

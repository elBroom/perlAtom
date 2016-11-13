CREATE TABLE IF NOT EXISTS `user` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `uname` varchar(100) NOT NULL,
  `karma` decimal(10,1) NOT NULL,
  `rating` decimal(10,1) NOT NULL,
  `last_update` datetime NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `uname` (`uname`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `post` (
  `id_post` int(11) NOT NULL,
  `author` varchar(100) NOT NULL,
  `theme` varchar(255) NOT NULL,
  `rating` decimal(10,1) NOT NULL,
  `count_view` varchar(10) NOT NULL,
  `count_star` int(11) NOT NULL,
  `last_update` datetime NOT NULL,
  PRIMARY KEY (`id_post`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `commenter` (
  `id_user` int(11) NOT NULL,
  `id_post` int(11) NOT NULL,
  PRIMARY KEY (`id_user`,`id_post`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

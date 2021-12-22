CREATE TABLE `draw_text` (
 `id` int(10) NOT NULL AUTO_INCREMENT,
 `creator` varchar(50) DEFAULT NULL,
 `content` text DEFAULT NULL,
 `font` int(11) DEFAULT NULL,
 `color` text DEFAULT NULL,
 `radius` int(11) DEFAULT NULL,
 `xyz` text DEFAULT NULL,
 `scale_multiplier` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
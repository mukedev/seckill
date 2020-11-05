/*
SQLyog Ultimate v11.27 (32 bit)
MySQL - 5.5.49 : Database - seckill
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`seckill` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `seckill`;

/*Table structure for table `seckill` */

DROP TABLE IF EXISTS `seckill`;

CREATE TABLE `seckill` (
  `seckill_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品库存ID',
  `name` varchar(150) NOT NULL COMMENT '商品名字',
  `number` int(11) NOT NULL COMMENT '库存数量',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `start_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '秒杀开始时间',
  `end_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT '秒杀结束时间',
  PRIMARY KEY (`seckill_id`),
  KEY `idx_start_time` (`start_time`),
  KEY `idx_end_time` (`end_time`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1004 DEFAULT CHARSET=utf8 COMMENT='秒杀库存表';

/*Data for the table `seckill` */

insert  into `seckill`(`seckill_id`,`name`,`number`,`create_time`,`start_time`,`end_time`) values (1000,'1000元秒杀iphone6',97,'2016-05-31 10:31:57','2016-06-07 00:00:00','2016-06-27 00:00:00'),(1001,'500元秒杀ipad2',197,'2016-05-18 10:31:57','2016-06-08 00:00:00','2016-06-27 00:00:00'),(1002,'300元秒杀小米4',300,'2016-05-31 10:31:57','2016-06-09 00:00:00','2016-06-27 00:00:00'),(1003,'200元秒杀红米note',400,'2016-05-31 10:31:57','2016-06-10 00:00:00','2016-06-27 00:00:00');

/*Table structure for table `success_killed` */

DROP TABLE IF EXISTS `success_killed`;

CREATE TABLE `success_killed` (
  `seckill_id` bigint(20) NOT NULL COMMENT '秒杀商品ID',
  `user_phone` bigint(20) NOT NULL COMMENT '用户手机号',
  `state` tinyint(4) NOT NULL DEFAULT '-1' COMMENT '状态标识：-1：无效    0：成功   1：已付款   2：已发货',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`seckill_id`,`user_phone`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='秒杀库成功明细表';

/*Data for the table `success_killed` */

insert  into `success_killed`(`seckill_id`,`user_phone`,`state`,`create_time`) values (1000,13570958590,-1,'2016-06-08 17:32:23'),(1001,12376540987,-1,'2016-06-08 17:26:21'),(1001,13570958590,-1,'2016-06-08 17:32:45');

/* Procedure structure for procedure `execute_seckill` */

/*!50003 DROP PROCEDURE IF EXISTS  `execute_seckill` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`root`@`localhost` PROCEDURE `execute_seckill`(in v_seckill_id bigint,in v_phone bigint,
	in v_kill_time timestamp,out r_result int)
begin
	declare insert_count int default 0;
	START TRANSACTION;
	insert ignore into success_killed
		(seckill_id,user_phone,create_time)
		values(v_seckill_id,v_phone,v_kill_time);
	select row_count() into insert_count;
	if (insert_count = 0) then
		rollback;
		set r_result = -1;
	elseif (insert_count < 0) then
		ROLLBACK;
		set r_result = -2;
	else
			update seckill
			set number = number-1 
			where seckill_id = v_seckill_id
			   and end_time > v_kill_time
			   and start_time < v_kill_time
			   and number > 0;
		   SELECT ROW_COUNT() INTO insert_count;
		   IF (insert_count = 0) THEN
			ROLLBACK;
			set r_result = 0;
		   ELSEIF (insert_count < 0) THEN
			ROLLBACK;
			SET r_result = -2;
		   else 
			commit;
			set r_result = 1;
		   end if;
	end if;
 end */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

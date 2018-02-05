-- ------------------------------------------------------------------------------------------------------------------ --
-- In this procedure, a check for indexing is first done and then removed.                                            --
-- Here two arguments are asked, namely the table name and the column name.                                           --
-- ------------------------------------------------------------------------------------------------------------------ --


DROP PROCEDURE IF EXISTS drop_index_if_exists;

DELIMITER ;;
CREATE PROCEDURE `drop_index_if_exists`(in theTable varchar(128), in theIndexName varchar(128) )
BEGIN
 IF((SELECT COUNT(*) AS index_exists FROM information_schema.statistics WHERE TABLE_SCHEMA = DATABASE() and table_name =
theTable AND index_name = theIndexName) > 0) THEN
   SET @s = CONCAT('DROP INDEX ' , theIndexName , ' ON ' , theTable);
   PREPARE stmt FROM @s;
   EXECUTE stmt;
 END IF;
END;;
DELIMITER ;
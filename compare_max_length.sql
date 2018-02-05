-- ------------------------------------------------------------------------------------------------------------------ --
-- In this procedure, an imposed table structure in column width is compared with the table structure created and     --
-- and inserted with all the records from a datadump.                                                                 --
-- The only table naming convention is that the table name is the same is the imposed table tailing  _COMPARE         --
-- ------------------------------------------------------------------------------------------------------------------ --


drop procedure if exists compare_max_length;
DELIMITER ;;
CREATE PROCEDURE `compare_max_length`(in tablename varchar(64),
  in table_schema varchar(64))

	BEGIN
	DECLARE i INT DEFAULT 0;
	DECLARE tablename_COMPARE VARCHAR(36);
	SET tablename_COMPARE = (select Concat(tablename, '_COMPARE'));
	Drop table if exists `_max_length`;
	CREATE TABLE `_max_length` (
  		`table_name` varchar(64) NOT NULL,
  		`column_name` varchar(64) NOT NULL,
  		`max_length` int(5) DEFAULT NULL,
  		`max_length_COMPARE` int(5) DEFAULT NULL
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    SET SESSION GROUP_CONCAT_MAX_LEN=1000000;
    Set @check = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = table_schema AND TABLE_NAME = tablename);
	  Set @check_COMPARE = (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = table_schema AND TABLE_NAME = tablename_COMPARE limit 1);

	If (select @check = 1) and (Select @check_COMPARE = 1) then
		set @count_columns = (SELECT count(COLUMN_NAME)
								FROM `INFORMATION_SCHEMA`.`COLUMNS` WHERE `TABLE_SCHEMA`= table_schema
    							AND `TABLE_NAME`= tablename);
    	Drop table if exists _Table_Columns;
    	CREATE TABLE _Table_Columns as
  			SELECT concat('Insert into _max_length (table_name, column_name, max_length) SELECT "',tablename, '", "',column_name,'", MAX(LENGTH(',COLUMN_NAME,'))
  			from `', tablename,'`;') as statement FROM INFORMATION_SCHEMA.COLUMNS
  				WHERE TABLE_SCHEMA = table_schema AND table_name = tablename
  				ORDER BY ordinal_position;

    	WHILE i<@count_columns DO
			set @SQL := (select statement from _Table_Columns limit i, 1);
			PREPARE stmt FROM @SQL;
			EXECUTE stmt;
			SET i := i + 1;
		END WHILE;
	end if;
	UPDATE _max_length ML JOIN INFORMATION_SCHEMA.COLUMNS IC ON IC.COLUMN_NAME = ML.column_name SET `max_length_COMPARE` = IC.CHARACTER_MAXIMUM_LENGTH WHERE TABLE_SCHEMA = table_schema AND IC.TABLE_NAME = tablename_COMPARE;
END;;

DELIMITER ;
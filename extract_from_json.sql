-- ------------------------------------------------------------------------------------------------------------------ --
-- I have written this function if there is no direct json facility available within your SQL development             --
-- environment  For easily extracting items based on json data, tag name and separator that needs to be passed to.    -- 
-- this function.                                                                                                     --
-- ------------------------------------------------------------------------------------------------------------------ --


Drop function if exists `EXTRACT_FROM_JSON` ;
Delimiter ;;

Create function `EXTRACT_FROM_JSON`(json tinytext, search varchar(124), delimiter_char varchar(1))
Returns tinytext
Reads sql data

Begin

	Declare item_count INT;
	Declare i INT;
	Declare extract tinytext;
  Declare position_found INT;

  Set @json = json;
	Set @search = search;
	Set @delimiter = delimiter_char;
	Set item_count = (Select length(@json) - length(replace(@json,@delimiter,'')));
	Set i= 1;
  Set position_found = (select locate(search, @json));

  If position_found > 0 then
	  search_loop:
		  While i <= item_count do begin
			  Set extract = (Select substring_index(substring(@json,locate(@search,@json)+length(@search)+3), @delimiter,1));
		    Set extract = (select replace(extract,'"',''));
        Set i = i + 1;
		  End; End while;
  Else
    Set extract = null;
  End if;

  Return replace(extract,'\n}','');

END ;;

Delimiter ;
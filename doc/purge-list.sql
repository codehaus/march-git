BEGIN;
SELECT * FROM LISTS WHERE ADDRESS = 'list-address';
UPDATE MESSAGES SET CONTENT_PART_ID = NULL WHERE LIST_ID = 64; -- You could come unstuck if there were logical inconsistencies in the linkages; however that we'll live with
DELETE FROM PARTS WHERE MESSAGE_ID IN (SELECT ID FROM MESSAGES WHERE LIST_ID = 64);
DELETE FROM MESSAGES WHERE LIST_ID = 64;
update lists set messages_count = 0 where id = 64;
ROLLBACK;

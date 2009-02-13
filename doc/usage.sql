 
 SELECT pg_database.datname,
 pg_shadow.usename AS owner,
 pg_database_size(pg_database.datname) AS size,
 pg_size_pretty(pg_database_size(pg_database.datname)) AS pretty_size
 FROM pg_database
 JOIN pg_shadow ON pg_database.datdba = pg_shadow.usesysid;
 
 
 
SELECT tablename, pg_size_pretty( pg_total_relation_size(tablename) ) from pg_tables where tableowner not in ('postgres')
order by pg_total_relation_size(tablename) desc;


 
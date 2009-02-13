select * from ts_stat('select data_tsv from contents order by id desc limit 100') ts
where not exists (select * from ignorewords iw where ts.word::varchar = iw.word)
order by ndoc desc, nentry desc,word limit 10;


 create table ignorewords(word varchar);
   create index pk_iw on ignorewords(word);
   insert into ignorewords values ('to');
   insert into ignorewords values ('this');
   insert into ignorewords values ('from');
   insert into ignorewords values ('list');
   insert into ignorewords values ('please');
   insert into ignorewords values ('unsubscribe');
   insert into ignorewords values ('visit');
   insert into ignorewords values ('the');
   insert into ignorewords values ('xircles.codehaus.org');
   insert into ignorewords values ('xircles.codehaus.org/manage_email');
   insert into ignorewords values ('message');
   insert into ignorewords values ('of');
   insert into ignorewords values ('it');
   insert into ignorewords values ('on');
   insert into ignorewords values ('for');
   insert into ignorewords values ('is');
   insert into ignorewords values ('you');
   insert into ignorewords values ('if');
   insert into ignorewords values ('and');
   insert into ignorewords values ('in');     
   insert into ignorewords values ('by');
   insert into ignorewords values ('more');
   insert into ignorewords values ('sent');
   insert into ignorewords values ('a');
   insert into ignorewords values ('see');
   insert into ignorewords values ('one');
   insert into ignorewords values ('type');
   insert into ignorewords values ('i');
     insert into ignorewords values ('have');
     insert into ignorewords values ('was');
     insert into ignorewords values ('has');
     insert into ignorewords values ('been');
     insert into ignorewords values ('or');
     insert into ignorewords values ('an');
     
   select 'insert into ignorewords values (''' || word || ''');' from ts_stat('select data_tsv from contents order by id desc limit 100') ts
   where not exists (select * from ignorewords iw where ts.word::varchar = iw.word)
   order by ndoc desc, nentry desc,word limit 10;
     
     
 select * from ts_stat('select data_tsv from contents order by id desc limit 100') ts
 where not exists (select * from ignorewords iw where ts.word::varchar = iw.word)
 order by ndoc desc, nentry desc,word limit 10;
 
 select * from ts_stat('select subject_tsv FROM messages order by id desc limit 100') ts
 where not exists (select * from ignorewords iw where ts.word::varchar = iw.word)
 order by ndoc desc, nentry desc,word limit 10;
 
-- So we're looking for new things hitting the mail archives
-- that we haven't seen recently.
--
-- So we grab all the words from last 100 messages (the now - interesting)
-- And all the words from the last 1000 messages (the past - uninteresting)
-- then we filter out 
begin;

create temporary table words_now ON COMMIT DROP as 
  select * from ts_stat('select strip(data_tsv) from contents c order by id desc limit 100 offset 0') ts
  order by ndoc desc, nentry desc,word;

create temporary table words_earlier ON COMMIT DROP as 
  select * from ts_stat('select strip(data_tsv) from contents c order by id desc limit 200 offset 101') ts
  order by ndoc desc, nentry desc,word;

create index we_word on words_earlier(word);
     
select word, nentry from words_now wn
 where not exists (select * from words_earlier we where we.word = wn.word)
   and nentry > 5
 order by nentry desc;
commit;
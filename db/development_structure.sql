--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: contents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE contents (
    id integer NOT NULL,
    data bytea NOT NULL,
    content_type character varying(255) NOT NULL,
    clean boolean NOT NULL,
    length integer NOT NULL,
    message_id integer NOT NULL,
    list_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    data_indexed integer DEFAULT 0 NOT NULL,
    data_tsv tsvector
);


--
-- Name: days; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE days (
    id integer NOT NULL,
    dt date,
    is_weekday boolean,
    is_holiday boolean,
    y integer,
    fy integer,
    q integer,
    m integer,
    d integer,
    dw integer,
    monthname character varying(9),
    dayname character varying(9),
    w integer
);


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE emails (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favorites (
    id integer NOT NULL,
    user_id integer NOT NULL,
    target_type character varying(128) NOT NULL,
    target_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: group_hierarchies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE group_hierarchies (
    id integer NOT NULL,
    parent_group_id integer NOT NULL,
    parent_level integer NOT NULL,
    child_group_id integer NOT NULL,
    child_level integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE groups (
    id integer NOT NULL,
    parent_id integer,
    key character varying(64) NOT NULL,
    name character varying(128),
    url character varying(512),
    children_count integer DEFAULT 0 NOT NULL,
    lists_count integer DEFAULT 0 NOT NULL,
    domain character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    identifier character varying NOT NULL,
    description character varying
);


--
-- Name: list_alias; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE list_alias (
    id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE lists (
    id integer NOT NULL,
    group_id integer,
    address character varying(128) NOT NULL,
    url character varying(512),
    subscriber_address character varying(128),
    key character varying(255) NOT NULL,
    messages_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    identifier character varying NOT NULL,
    description character varying
);


--
-- Name: message_references; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE message_references (
    id integer NOT NULL,
    message_id integer NOT NULL,
    referenced_message_id822 character varying(128) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE messages (
    id integer NOT NULL,
    list_id integer NOT NULL,
    message_id822 character varying(128) NOT NULL,
    in_reply_to_message_id822 character varying(128),
    sent_at timestamp without time zone NOT NULL,
    from_address character varying(128) NOT NULL,
    from_header character varying(256) NOT NULL,
    from_name character varying(128),
    subject character varying(1024) DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT '2009-02-17 22:57:41.537336'::timestamp without time zone,
    indexed boolean DEFAULT false NOT NULL,
    content_part_id integer,
    source character varying(4096),
    updated_at timestamp with time zone,
    subject_tsv tsvector,
    rating_total integer DEFAULT 0,
    rating_count integer DEFAULT 0
);


--
-- Name: parts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE parts (
    id integer NOT NULL,
    message_id integer NOT NULL,
    content_type character varying(128) NOT NULL,
    name character varying(255),
    length integer,
    state character(1),
    content_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: ratings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ratings (
    id integer NOT NULL,
    user_id integer NOT NULL,
    message_id integer NOT NULL,
    value integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: stop_words; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stop_words (
    id integer NOT NULL,
    word character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    identifier character varying(255) NOT NULL,
    nickname character varying(255),
    fullname character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sp_active_lists(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_active_lists(pgroup_id integer, plimit integer) RETURNS SETOF lists
    AS $$
DECLARE
  list_id INTEGER;
  list LISTS%ROWTYPE;
  max_message_id INTEGER;
BEGIN
  SELECT MAX(id) INTO max_message_id FROM messages;
  RAISE NOTICE 'Limit is %', pLIMIT;
  RAISE NOTICE 'Latest message is %', max_message_id;
  
  -- Look for all lists active in the last 500 messages; then sort by descending order
  -- This will be confused by a bulk loader running; but will be quickly fixed as new messages come through
  FOR list_id IN
     SELECT L.ID
      FROM GROUP_HIERARCHIES GH, LISTS L, MESSAGES M
      WHERE GH.PARENT_GROUP_ID = pGROUP_ID
        AND CHILD_GROUP_ID = L.GROUP_ID
        AND L.ID = M.LIST_ID
        AND M.ID >= (max_message_id - 500)
      GROUP BY L.ID
      ORDER BY COUNT(*) DESC
  LOOP
    SELECT * INTO list FROM LISTS L WHERE L.ID = list_id;
    RETURN NEXT list;
  END LOOP;
  
  RETURN;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_build_days(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_build_days(start date, finish date) RETURNS void
    AS $$
DECLARE
  current DATE;
BEGIN
  RAISE NOTICE 'Clearing days';
  TRUNCATE TABLE days;
  
  SELECT start INTO current;
  
  RAISE NOTICE 'Creating days';
  WHILE current < finish
  LOOP
      INSERT INTO days (dt) VALUES (current);
      SELECT current + 1 INTO current;
  END LOOP;
  
  RAISE NOTICE 'Setting up data';
  UPDATE days SET 
      is_weekday = CASE  
          WHEN DATE_PART('DOW', dt) IN (1,7)  
          THEN false 
          ELSE true END, 
      is_holiday = false, 
      Y = EXTRACT(YEAR FROM dt),
      Q = CASE 
          WHEN EXTRACT(MONTH FROM dt) <= 3 THEN 1 
          WHEN EXTRACT(MONTH FROM dt) <= 6 THEN 2 
          WHEN EXTRACT(MONTH FROM dt) <= 9 THEN 3 
          ELSE 4 END,  
        M = EXTRACT(MONTH FROM dt),  
      D = EXTRACT(DAY FROM dt),  
      DW = DATE_PART('DOW', dt),  
      monthname = TO_CHAR(dt, 'Month'),  
      dayname = TO_CHAR(dt, 'Day'),  
      W = EXTRACT(WEEK FROM dt);
      
  RETURN;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_contents_data_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_contents_data_trigger() RETURNS trigger
    AS $$
DECLARE
  data_text TEXT;
  indexed_level INTEGER;
  indexed_length INTEGER;
BEGIN
  indexed_level := 4; -- Controls what round of indexing we're doing (useful for incremental changes to the index)
  indexed_length := 32768; -- Only index the first portion of a message
  
  -- Are we attempting to index non text/plain data
  -- Rationale: Non text would need cleaning (e.g. HTML / ZIP attachments etc)
  IF SUBSTRING(new.content_type, 1, 10) <> 'text/plain' AND SUBSTRING(new.content_type, 1, 9) <> 'text/html' THEN
    new.data_tsv := NULL;
    RETURN new;
  END IF;
  
  -- Is our index is up-to-date?
  IF new.data_tsv IS NOT NULL AND new.data_indexed >= indexed_level THEN
    RETURN new;
  END IF;
  
  data_text := encode(new.data,'escape');
  -- Limit index to first "indexed_length" portion
  IF LENGTH(data_text) > indexed_length THEN
    data_text := SUBSTRING(data_text, 1, indexed_length);
  END IF;
  
  SET MAINTENANCE_WORK_MEM = '1GB';
  new.data_tsv := strip(to_tsvector('march_config', data_text));
  new.data_indexed := indexed_level;
  
  RETURN new;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_get_first_message_in_thread(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_get_first_message_in_thread(pmessage_id integer) RETURNS SETOF messages
    AS $$
DECLARE
  current MESSAGES%rowtype;
  parent MESSAGES%rowtype;
  depth INTEGER;
BEGIN
  depth := 0;
  
  SELECT * INTO current FROM MESSAGES WHERE ID = pMESSAGE_ID;
  
  IF current IS NULL THEN
    RETURN;
  END IF;
  
  
  FOR depth in 1..10 LOOP
    IF current.in_reply_to_message_id822 IS NULL THEN
      RETURN NEXT current;
      RETURN;
    END IF;
    
    SELECT * INTO parent 
    FROM MESSAGES 
    WHERE message_id822 = current.in_reply_to_message_id822
      AND list_id = current.list_id
    LIMIT 1;
    
    IF parent IS NULL THEN
      RETURN NEXT current;
      RETURN;
    END IF;
    
    current := parent;
  END LOOP;
  
  RETURN NEXT current;
  RETURN;

END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_get_thread(integer, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_get_thread(plist_id integer, pmessage_id822 character varying, pdepth integer) RETURNS SETOF messages
    AS $$
DECLARE
  current MESSAGES%rowtype;
  child VARCHAR;
BEGIN
  SELECT * INTO current FROM MESSAGES WHERE list_id = plist_id AND message_id822 = pmessage_id822;
  IF current IS NULL THEN
    RETURN;
  END IF;
  
  RETURN NEXT current;
  
  IF pdepth = 0 THEN
    RETURN;
  END IF;

  FOR child IN 
   SELECT DISTINCT message_id822
    FROM messages
    WHERE list_id = plist_id
      AND in_reply_to_message_id822 = current.message_id822
  LOOP
    RETURN QUERY SELECT * FROM sp_get_thread(plist_id, child, pdepth - 1);
  END LOOP;
  
  RETURN;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_index_content_type(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_index_content_type(content_type character varying) RETURNS boolean
    AS $$
BEGIN
  RETURN SUBSTRING(content_type, 1, 10) = 'text/plain'
      OR SUBSTRING(content_type, 1, 9) = 'text/html';
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_latest_messages_for_group(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_latest_messages_for_group(pgroup_id integer, plimit integer) RETURNS SETOF messages
    AS $$
DECLARE
  list LISTS%rowtype;
BEGIN
  -- For each list in the closure, grab the latest pLimit messages
  -- The caller will need to resort by sent_at and grab their limit of messages
  FOR list IN 
   SELECT L.ID 
    FROM GROUP_HIERARCHIES GH, LISTS L
    WHERE GH.PARENT_GROUP_ID = pGROUP_ID
      AND CHILD_GROUP_ID = L.GROUP_ID
  LOOP
    RETURN QUERY SELECT * 
                 FROM MESSAGES 
                 WHERE LIST_ID = LIST.ID 
                   AND SENT_AT > NOW() - INTERVAL '1 WEEK' -- Helps limit mega result sets due to inactive lists
                 ORDER BY SENT_AT DESC LIMIT pLIMIT;
  END LOOP;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_lists_in_group(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_lists_in_group(p_group_id integer) RETURNS SETOF lists
    AS $$
BEGIN
  IF p_group_id IS NULL THEN
    RETURN QUERY SELECT * FROM LISTS;
  ELSE
    RETURN QUERY 
      SELECT * 
      FROM lists
      WHERE group_id IN (
              SELECT CHILD_GROUP_ID 
              FROM GROUP_HIERARCHIES GH 
              WHERE GH.PARENT_GROUP_ID = p_group_id
            );
  END IF;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_message_is_spam(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_message_is_spam(message_id integer) RETURNS boolean
    AS $$
DECLARE
  current MESSAGES%rowtype;
BEGIN
  IF message_id IS NULL THEN
    RETURN FALSE;
  END IF;
  
  SELECT * INTO current FROM messages WHERE id = message_id;
  
  IF current.rating_total < 0 THEN
    RETURN TRUE;
  END IF;
  
  RETURN FALSE;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_populate_counts(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_populate_counts() RETURNS void
    AS $$
DECLARE
  group groups%ROWTYPE;
  list  lists%ROWTYPE;
BEGIN

  FOR group IN SELECT * FROM groups
  LOOP
    RAISE NOTICE ' Processing group %', group.identifier;
    UPDATE groups
       SET children_count = (SELECT COUNT(*) FROM groups WHERE parent_id = group.id),
           lists_count = (SELECT COUNT(*) FROM lists WHERE group_id = group.id)
     WHERE id = group.id;
  END LOOP;  

  FOR list IN SELECT * FROM lists
  LOOP
    RAISE NOTICE ' Processing list %', list.identifier;
    UPDATE lists
       SET messages_count = (SELECT COUNT(*) FROM messages WHERE list_id = list.id)
     WHERE id = list.id;
  END LOOP;  
  RETURN;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_populate_group_closure(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_populate_group_closure() RETURNS void
    AS $$
DECLARE closure_distance int;
BEGIN
TRUNCATE TABLE GROUP_HIERARCHIES;

-- Seed the closure table with top-level groups
INSERT INTO GROUP_HIERARCHIES
( PARENT_GROUP_ID, PARENT_LEVEL, CHILD_GROUP_ID, CHILD_LEVEL )
SELECT id, 1, id, 1
  FROM GROUPS
 WHERE PARENT_ID IS NULL;

-- Progressively build lower levels
-- XXX Should really abort if nothing affected in a given pass
FOR closure_distance in 1..20 LOOP
  RAISE NOTICE 'Processing loop %', closure_distance;
  INSERT INTO GROUP_HIERARCHIES
  ( PARENT_GROUP_ID, PARENT_LEVEL, CHILD_GROUP_ID, CHILD_LEVEL )
  SELECT GH.PARENT_GROUP_ID, GH.PARENT_LEVEL, CHILD.ID, closure_distance + 1
  FROM GROUP_HIERARCHIES GH, GROUPS CHILD
  WHERE GH.CHILD_GROUP_ID = CHILD.PARENT_ID
    AND GH.CHILD_LEVEL = closure_distance;
    
  INSERT INTO GROUP_HIERARCHIES
  ( PARENT_GROUP_ID, PARENT_LEVEL, CHILD_GROUP_ID, CHILD_LEVEL )
  SELECT DISTINCT child_group_id, child_level, child_group_id, child_level
  FROM GROUP_HIERARCHIES
  WHERE
    child_level = closure_distance + 1;
  
END LOOP;


END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_search_group(integer, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_search_group(p_group_id integer, p_query tsquery) RETURNS SETOF messages
    AS $$
BEGIN
  SET STATEMENT_TIMEOUT TO 15;
  RETURN QUERY SELECT m.*
    FROM messages m
    WHERE m.id IN (
        SELECT message_id FROM (
          SELECT c.message_id 
          FROM contents c
          WHERE data_tsv @@ p_query
            AND list_id IN (SELECT id FROM lists WHERE group_id = p_group_id) --(SELECT id FROM sp_lists_in_group(p_group_id))
          LIMIT 25
        ) PARTA
          
        UNION ALL 
        
        SELECT id FROM (
          SELECT id
          FROM messages m
          WHERE subject_tsv @@ p_query
            AND list_id IN (SELECT id FROM lists WHERE group_id = p_group_id) --(SELECT id FROM sp_lists_in_group(p_group_id))
          LIMIT 25
        ) PARTB
      )
    ORDER BY SENT_AT DESC
    LIMIT 25;
    SET STATEMENT_TIMEOUT TO DEFAULT;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: sp_search_list(integer, tsquery); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sp_search_list(p_list_id integer, p_query tsquery) RETURNS SETOF messages
    AS $$
BEGIN
  SET STATEMENT_TIMEOUT TO 15;
  RETURN QUERY SELECT m.*
    FROM messages m
    WHERE m.id IN (
      SELECT message_id FROM (
        SELECT
          c.message_id
        FROM contents c
        WHERE data_tsv @@ p_query
          AND list_id = p_list_id
        LIMIT 25
      ) PARTA
        
      UNION ALL
      
      SELECT id FROM (
        SELECT id
        FROM messages m
        WHERE subject_tsv @@ p_query
          AND list_id = p_list_id
        LIMIT 25
      ) PARTB
    )
    ORDER BY SENT_AT DESC
    LIMIT 25;
    SET STATEMENT_TIMEOUT TO DEFAULT;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: trg_contents_denormalization(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_contents_denormalization() RETURNS trigger
    AS $$
DECLARE
BEGIN
  SET MAINTENANCE_WORK_MEM = '1GB';
  IF new.message_id IS NULL THEN
    SELECT message_id INTO new.message_id FROM parts WHERE content_id = new.id;
  END IF;
  
  IF new.list_id IS NULL THEN
    SELECT list_id INTO new.list_id FROM messages WHERE id = new.message_id;
  END IF;
  
  RETURN new;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: trg_message_subject(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_message_subject() RETURNS trigger
    AS $$
BEGIN
  new.subject_tsv := strip(to_tsvector('simple', new.subject));
  RETURN new;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: trg_rating_message(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trg_rating_message() RETURNS trigger
    AS $$
DECLARE
  total_delta INTEGER;
  count_delta INTEGER;
  message_id INTEGER;
BEGIN
  total_delta := 0;
  count_delta := 0;

  IF TG_OP = 'UPDATE' THEN
    IF old.message_id <> new.message_id THEN
      RAISE EXCEPTION 'You can not move a rating from one message to another';
    END IF;
  END IF;
  
  -- Phase 1; subtract the current values
  IF (TG_OP = 'DELETE') OR (TG_OP = 'UPDATE') THEN
    message_id := old.message_id;
    total_delta := total_delta - COALESCE(old.value, 0);
    count_delta := count_delta - 1;
  END IF;
  
  -- Phase 2; add the new values
  IF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
    message_id := new.message_id;
    total_delta := total_delta + COALESCE(new.value, 0);
    count_delta := count_delta + 1;
  END IF;
  
  -- For big instances, you may not have zeroed the messages initially
  UPDATE messages m
  SET rating_total = COALESCE(rating_total, 0) + total_delta,
      rating_count = COALESCE(rating_count, 0) + count_delta
  WHERE id = message_id;
  
  IF TG_OP = 'DELETE' THEN
    RETURN old;
  ELSE
    RETURN new;
  END IF;
END;
$$
    LANGUAGE plpgsql;


--
-- Name: march_dict; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: -
--

CREATE TEXT SEARCH DICTIONARY march_dict (
    TEMPLATE = pg_catalog.simple,
    stopwords = 'march' );


--
-- Name: march_config; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: -
--

CREATE TEXT SEARCH CONFIGURATION march_config (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR asciiword WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR word WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR hword_part WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR hword_asciipart WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR asciihword WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR hword WITH march_dict;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION march_config
    ADD MAPPING FOR uint WITH simple;


--
-- Name: contents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: contents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contents_id_seq OWNED BY contents.id;


--
-- Name: days_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE days_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: days_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE days_id_seq OWNED BY days.id;


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favorites_id_seq OWNED BY favorites.id;


--
-- Name: group_hierarchies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE group_hierarchies_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: group_hierarchies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE group_hierarchies_id_seq OWNED BY group_hierarchies.id;


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: list_alias_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE list_alias_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: list_alias_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE list_alias_id_seq OWNED BY list_alias.id;


--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lists_id_seq OWNED BY lists.id;


--
-- Name: message_references_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE message_references_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: message_references_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE message_references_id_seq OWNED BY message_references.id;


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE parts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE parts_id_seq OWNED BY parts.id;


--
-- Name: ratings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ratings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: ratings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ratings_id_seq OWNED BY ratings.id;


--
-- Name: stop_words_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stop_words_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: stop_words_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stop_words_id_seq OWNED BY stop_words.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE contents ALTER COLUMN id SET DEFAULT nextval('contents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE days ALTER COLUMN id SET DEFAULT nextval('days_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE favorites ALTER COLUMN id SET DEFAULT nextval('favorites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE group_hierarchies ALTER COLUMN id SET DEFAULT nextval('group_hierarchies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE list_alias ALTER COLUMN id SET DEFAULT nextval('list_alias_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE lists ALTER COLUMN id SET DEFAULT nextval('lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE message_references ALTER COLUMN id SET DEFAULT nextval('message_references_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE parts ALTER COLUMN id SET DEFAULT nextval('parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ratings ALTER COLUMN id SET DEFAULT nextval('ratings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE stop_words ALTER COLUMN id SET DEFAULT nextval('stop_words_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (id);


--
-- Name: days_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY days
    ADD CONSTRAINT days_pkey PRIMARY KEY (id);


--
-- Name: emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: group_hierarchies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY group_hierarchies
    ADD CONSTRAINT group_hierarchies_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: list_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY list_alias
    ADD CONSTRAINT list_alias_pkey PRIMARY KEY (id);


--
-- Name: lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: message_references_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY message_references
    ADD CONSTRAINT message_references_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (id);


--
-- Name: ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_pkey PRIMARY KEY (id);


--
-- Name: stop_words_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stop_words
    ADD CONSTRAINT stop_words_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_data_tsv_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_data_tsv_gin ON contents USING gin (data_tsv);


--
-- Name: idx_message_subject_tsv_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_message_subject_tsv_gin ON messages USING gin (subject_tsv);


--
-- Name: index_contents_on_data_indexed_and_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contents_on_data_indexed_and_id ON contents USING btree (data_indexed, id);


--
-- Name: index_contents_on_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contents_on_list_id ON contents USING btree (list_id);


--
-- Name: index_contents_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_contents_on_message_id ON contents USING btree (message_id);


--
-- Name: index_groups_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_identifier ON groups USING btree (identifier);


--
-- Name: index_groups_on_parent_id_and_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_groups_on_parent_id_and_key ON groups USING btree (parent_id, key);


--
-- Name: index_lists_on_group_id_and_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lists_on_group_id_and_key ON lists USING btree (group_id, key);


--
-- Name: index_lists_on_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_lists_on_identifier ON lists USING btree (identifier);


--
-- Name: index_message_references_on_referenced_message_id822; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_message_references_on_referenced_message_id822 ON message_references USING btree (referenced_message_id822);


--
-- Name: index_messages_on_in_reply_to_message_id822; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_in_reply_to_message_id822 ON messages USING btree (in_reply_to_message_id822);


--
-- Name: index_messages_on_indexed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_indexed ON messages USING btree (indexed);


--
-- Name: index_messages_on_list_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_list_id ON messages USING btree (list_id);


--
-- Name: index_messages_on_list_id_and_sent_at_and_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_list_id_and_sent_at_and_id ON messages USING btree (list_id, sent_at, id);


--
-- Name: index_messages_on_message_id822; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_messages_on_message_id822 ON messages USING btree (message_id822);


--
-- Name: index_parts_on_content_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_parts_on_content_id ON parts USING btree (content_id);


--
-- Name: index_parts_on_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_parts_on_message_id ON parts USING btree (message_id);


--
-- Name: index_stop_words_on_word; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stop_words_on_word ON stop_words USING btree (word);


--
-- Name: message_references_message_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX message_references_message_id ON message_references USING btree (message_id);


--
-- Name: messages_content_part_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX messages_content_part_id ON messages USING btree (content_part_id);


--
-- Name: messages_source; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX messages_source ON messages USING btree (source);


--
-- Name: part_state; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX part_state ON parts USING btree (state);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: contents_data_tsv_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER contents_data_tsv_update
    BEFORE INSERT OR UPDATE ON contents
    FOR EACH ROW
    EXECUTE PROCEDURE sp_contents_data_trigger();


--
-- Name: message_subject_tsv_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER message_subject_tsv_update
    BEFORE INSERT OR UPDATE ON messages
    FOR EACH ROW
    EXECUTE PROCEDURE trg_message_subject();


--
-- Name: rating_message_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER rating_message_update
    BEFORE INSERT OR DELETE OR UPDATE ON ratings
    FOR EACH ROW
    EXECUTE PROCEDURE trg_rating_message();


--
-- Name: trg_contents_denormalization; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_contents_denormalization
    BEFORE INSERT OR UPDATE ON contents
    FOR EACH ROW
    EXECUTE PROCEDURE trg_contents_denormalization();


--
-- Name: contents_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_list_id_fkey FOREIGN KEY (list_id) REFERENCES lists(id);


--
-- Name: contents_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id);


--
-- Name: favorites_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY favorites
    ADD CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE;


--
-- Name: group_hierarchies_child_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_hierarchies
    ADD CONSTRAINT group_hierarchies_child_group_id_fkey FOREIGN KEY (child_group_id) REFERENCES groups(id);


--
-- Name: group_hierarchies_parent_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY group_hierarchies
    ADD CONSTRAINT group_hierarchies_parent_group_id_fkey FOREIGN KEY (parent_group_id) REFERENCES groups(id);


--
-- Name: groups_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES groups(id) DEFERRABLE;


--
-- Name: lists_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_group_id_fkey FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- Name: message_references_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY message_references
    ADD CONSTRAINT message_references_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id);


--
-- Name: messages_content_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_content_part_id_fkey FOREIGN KEY (content_part_id) REFERENCES parts(id);


--
-- Name: messages_list_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_list_id_fkey FOREIGN KEY (list_id) REFERENCES lists(id);


--
-- Name: parts_content_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parts
    ADD CONSTRAINT parts_content_id_fkey FOREIGN KEY (content_id) REFERENCES contents(id);


--
-- Name: parts_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY parts
    ADD CONSTRAINT parts_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id);


--
-- Name: ratings_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(id) DEFERRABLE;


--
-- Name: ratings_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ratings
    ADD CONSTRAINT ratings_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) DEFERRABLE;


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('20080705030723');

INSERT INTO schema_migrations (version) VALUES ('20080707132228');

INSERT INTO schema_migrations (version) VALUES ('20080712095550');

INSERT INTO schema_migrations (version) VALUES ('20080712131653');

INSERT INTO schema_migrations (version) VALUES ('20080719111607');

INSERT INTO schema_migrations (version) VALUES ('20080720030405');

INSERT INTO schema_migrations (version) VALUES ('20080722111127');

INSERT INTO schema_migrations (version) VALUES ('20080726224658');

INSERT INTO schema_migrations (version) VALUES ('20080728110804');

INSERT INTO schema_migrations (version) VALUES ('20080802035006');

INSERT INTO schema_migrations (version) VALUES ('20080802105217');

INSERT INTO schema_migrations (version) VALUES ('20080811132122');

INSERT INTO schema_migrations (version) VALUES ('20080828120117');

INSERT INTO schema_migrations (version) VALUES ('20080925124449');

INSERT INTO schema_migrations (version) VALUES ('20090215090439');
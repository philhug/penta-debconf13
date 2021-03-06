
-- this function creates a log function for each table found in the
-- log schema and registers those functions as trigger
CREATE OR REPLACE FUNCTION log.activate_logging() RETURNS VOID AS $$
  DECLARE
    logtable    RECORD;
    fundef      TEXT;
    trigdef     TEXT;
    trigname    TEXT;
    procname    TEXT;
    tablename   TEXT;
    tableschema TEXT;
    columns     TEXT;
    columns_old TEXT;
    columns_new TEXT;
  BEGIN
    FOR logtable IN
      SELECT table_name FROM information_schema.tables WHERE table_schema = 'log' AND EXISTS( SELECT 1 FROM information_schema.tables AS interior WHERE table_schema IN ('auth','public','debconf') AND interior.table_name = tables.table_name )
    LOOP
      tablename = logtable.table_name;
      SELECT INTO tableschema table_schema FROM information_schema.tables WHERE table_schema IN ('auth','public','debconf') AND table_name = tablename;
      RAISE NOTICE 'Creating log function for table %', tablename;
      -- (re)creating trigger function
      procname = tablename || '_log_function';

      SELECT INTO columns array_to_string(ARRAY(SELECT quote_ident(column_name::text) from information_schema.columns WHERE table_name = tablename AND table_schema = tableschema ORDER BY ordinal_position),',');
      SELECT INTO columns_old array_to_string(ARRAY(SELECT 'OLD.'||quote_ident(column_name::text) from information_schema.columns WHERE table_name = tablename AND table_schema = tableschema ORDER BY ordinal_position),',');
      SELECT INTO columns_new array_to_string(ARRAY(SELECT 'NEW.'||quote_ident(column_name::text) from information_schema.columns WHERE table_name = tablename AND table_schema = tableschema ORDER BY ordinal_position),',');

      fundef = $f$CREATE OR REPLACE FUNCTION log.$f$ || quote_ident( procname ) || $f$() RETURNS TRIGGER AS $i$
        BEGIN
          IF ( current_setting('pentabarf.transaction_id') IN ('','unset') ) THEN
            PERFORM set_config('pentabarf.transaction_id',nextval('base.log_transaction_log_transaction_id_seq')::text,TRUE);
            INSERT INTO log.log_transaction( log_transaction_id, person_id ) 
              VALUES ( currval('base.log_transaction_log_transaction_id_seq'), 
                CASE current_setting('pentabarf.person_id') WHEN '' THEN NULL WHEN 'unset' THEN NULL ELSE current_setting('pentabarf.person_id')::INTEGER END
            );
          END IF;
          IF ( TG_OP = 'DELETE' ) THEN
            INSERT INTO log.$f$ || quote_ident( tablename ) || $f$(log_transaction_id,log_operation,$f$ || columns || $f$) SELECT currval('base.log_transaction_log_transaction_id_seq'), 'D', $f$ || columns_old || $f$;
            RETURN OLD;
          ELSE
            INSERT INTO log.$f$ || quote_ident( tablename ) || $f$(log_transaction_id,log_operation,$f$ || columns || $f$) SELECT currval('base.log_transaction_log_transaction_id_seq'), substring( TG_OP, 1, 1 ), $f$ || columns_new || $f$;
            RETURN NEW;
          END IF;
          RETURN NULL;
        END;
      $i$ LANGUAGE plpgsql;$f$;
      EXECUTE fundef;

      trigname = tablename || '_log_trigger';
      -- enable function as trigger if it is not yet enabled
      IF ( NOT EXISTS( SELECT 1 FROM information_schema.triggers WHERE trigger_name = trigname AND event_object_schema = tableschema AND event_object_table = tablename ) ) THEN
        RAISE NOTICE 'Creating trigger for table %', tablename;
        trigdef = $t$CREATE TRIGGER $t$ || quote_ident( trigname ) || $t$ AFTER INSERT OR UPDATE OR DELETE ON $t$ || quote_ident( tableschema ) || '.' || quote_ident( tablename ) || $t$ FOR EACH ROW EXECUTE PROCEDURE log.$t$ || quote_ident( procname ) || $t$();$t$;
        EXECUTE trigdef;
      END IF;
    END LOOP;

  END;
$$ LANGUAGE plpgsql;

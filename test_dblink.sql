REM Validate Database Links
REM Private links under connected user and Public links
REM
REM Biju Thomas - 29-Oct-2013
REM
set serveroutput on size 99999
set pages 0 lines 300 trims on
col spoolfile new_value spoolfname
select '/tmp/checklinks_'||user ||'_'||
       substr(global_name, 1, instr(global_name,'.')-1)||
       '.txt' spoolfile from global_name;
spool '&spoolfname'
declare
 --
 -- Get list of links the user has access to
 cursor mylinks is select db_link, owner, created, host, username
                   from all_db_links;
 --
 -- Identify other links in the DB for information
 cursor otherlinks is select db_link, owner
                      from dba_db_links
                      minus
                      select db_link, owner
                      from all_db_links;
 dbname varchar2 (200);
 currentuser varchar2 (30);
 linkno number := 0;
begin

 -- Current database and connected user
 select name, user into dbname, currentuser from v$database;
 dbms_output.put_line('Verifying Database Links '||currentuser||'@'||dbname);
 dbms_output.put_line('========================================================');
 --
 for linkcur in mylinks loop
  linkno := linkno + 1;
  dbms_output.put_line('Checking Link: ' || linkno) ;
  dbms_output.put_line('Link Name    : ' || linkcur.db_link) ;
  dbms_output.put_line('Link Owner   : ' || linkcur.owner) ;
  dbms_output.put_line('Connect User : ' || linkcur.username) ;
  dbms_output.put_line('Connect To   : ' || linkcur.host) ;
  begin
    --
    -- Connect to the link to validate, get global name of destination database
    execute immediate 'select global_name from global_name@"'||linkcur.db_link||'"' into dbname;
    dbms_output.put_line('$$$$ DB LINK SUCCESSFULLY connected to '||dbname);
    --
    -- end the transaction and explicitly close the db link
    commit;
    execute immediate 'alter session close database link "'||linkcur.db_link||'"';
  exception
    --
    -- DB Link connection failed, show error message
    when others then
    dbms_output.put_line('@@@@ DB LINK FAILED  @@@@');
    dbms_output.put_line('Error: '||sqlerrm);
  end;
  dbms_output.put_line('---------------------------------------');
  dbms_output.put_line(' ');
 end loop;
 dbms_output.put_line('Tests Completed.');
 --
 -- List other Links in the DB
 dbms_output.put_line('Other Private Links in the Database');
 dbms_output.put_line('Connect as respective owner to validate these.');
 dbms_output.put_line('----------------------------------------------');
 for olinks in otherlinks loop
   dbms_output.put_line(olinks.owner ||' :: '||olinks.db_link);
 end loop;
end;
/

spool
spool off
set pages 99 lines 80 trims off
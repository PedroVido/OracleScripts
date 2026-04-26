--=======================================================================
-- SYSAUX 
--=======================================================================

--======================================================
-- Ver maiores consumidores 
--======================================================


 SELECT occupant_name, trunc(space_usage_kbytes/1024/1024,3) as "Consumo em GB" 
 FROM V$SYSAUX_OCCUPANTS
 WHERE space_usage_kbytes >0
 order by 2 desc;




--======================================================
 -- SQL_MANAGEMENT_BASE - As one of top Ofensors
--======================================================

-- Only unused plans

select count(*) FROM dba_sql_plan_baselines;


 SET SERVEROUTPUT ON
DECLARE
    l_result INTEGER;

    CURSOR c_baselines IS
 select sql_handle, plan_name from (
   SELECT sql_handle, plan_name
        FROM   dba_sql_plan_baselines
        WHERE  (enabled = 'NO' OR accepted = 'NO'))
    where rownum <= 100;-- Only unused plans

    v_count   NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Starting purge of unused SQL Plan Baselines ---');

    FOR rec IN c_baselines LOOP
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Purging: ' || rec.sql_handle || ' / ' || rec.plan_name);

            l_result :=  DBMS_SPM.DROP_SQL_PLAN_BASELINE (sql_handle  => 'rec.sql_handle', plan_name => 'rec.plan_name');

            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error purging ' || rec.plan_name || ': ' || SQLERRM);
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('--- Purge complete. Total purged: ' || v_count || ' ---');
END;
/
-----

DECLARE 
l_result INTEGER;
BEGIN 

l_result := DBMS_SPM.drop_sql_plan_baseline(sql_handle => 'SQL_009d12d43a2e7a89', plan_name => 'SQL_PLAN_0178kuhx2wyn9104eb16e');
l_result := DBMS_SPM.drop_sql_plan_baseline(sql_handle => 'SQL_009d1c57c3d2f566', plan_name => 'SQL_PLAN_0178waz1x5xb6eec2963d');
l_result := DBMS_SPM.drop_sql_plan_baseline(sql_handle => 'SQL_009ec75968c115b9', plan_name => 'SQL_PLAN_017q7b5nc25dt42c363c8');
l_result := DBMS_SPM.drop_sql_plan_baseline(sql_handle => 'SQL_009f0539df8cdfb1', plan_name => 'SQL_PLAN_017s577gstrxjdf983b2e');
END;
/


--======================================================
-- Check the espace free
--======================================================

select file_name,
       ceil( (nvl(hwm,1)*8192)/1024/1024 ) smallest,
       ceil( blocks*8192/1024/1024) currsize,
       ceil( blocks*8192/1024/1024) -
       ceil( (nvl(hwm,1)*8192)/1024/1024 ) savings,
	   AUTOEXTENSIBLE
from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
and tablespace_name = 'SYSAUX';

--======================================================
-- Resize datafiles
--======================================================

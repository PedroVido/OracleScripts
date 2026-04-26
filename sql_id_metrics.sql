-- Metrics SQL_ID por periodo

alter session set nls_date_format = 'DD-MON-YYYY HH24:MI:SS';

COL sql_text            FOR A50 HEADING "SQL exec."  WORD_WRAP TRUNC
COL first_load_time     FOR A25 HEADING "Primeira utilizacao" JUSTIFY LEFT
COL last_load_time      FOR A25 HEADING "Ultima utilizacao"   JUSTIFY LEFT
COL parsing_schema_name FOR A25 HEADING "Usuario analisado"   JUSTIFY LEFT

SELECT *
  FROM ( SELECT sql_id,
                 ROUND ( ( (cpu_time / 1000000) / 60), 2) AS "Tempo total de CPU",
                 executions AS "Quant. exec.",
                 rows_processed AS "Quant. linhas proc.",
                 disk_reads AS "Leituras no disco",
                 first_load_time,
                 last_load_time,
                 parsing_schema_name,
                 sql_text
            FROM v$sqlarea
           WHERE parsing_schema_name NOT IN ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
           --AND last_load_time > SYSDATE -1
            AND last_load_time BETWEEN TO_DATE('2026-02-01 22:38:00','YYYY-MM-DD HH24:MI:SS')
                                   AND TO_DATE('2026-02-09 17:38:00','YYYY-MM-DD HH24:MI:SS')
            --AND sql_id = 'fnxb6403rk29s'                       
        ORDER BY 2,7 DESC)
 WHERE ROWNUM <= 30;
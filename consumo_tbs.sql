-- ########################################################################################################
--                                                                                                       --
-- File Name     : consumo_tbs.sql                                                                       --
-- Description   : Displays info tablaspaces.                                                            --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @consumo_tbs                                                                          --
-- Last Modified : 05/07/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

COL TABLESPACE   FOR A35          HEADING 'Tablespace'
COL TBS_SIZE     FOR 999,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL TBS_EM_USO   FOR 999,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL TBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL FREE_SPACE   FOR 999,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL SPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL PERC         FOR 990          HEADING '%|Ocupacao'          JUSTIFY RIGHT
COL bigfile      FOR A7           HEADING 'BigFile'             JUSTIFY RIGHT
COL TBS_FILES    FOR 990          HEADING 'Qtde|Arquivos'       JUSTIFY LEFT
COL autoextensible    FOR A11          HEADING 'Auto|Extensible'       JUSTIFY LEFT
--set wrap off
set lines 145
set pages 999
set verify off

break on report on tablespace_name skip 1
compute sum label "Total: " of tbs_em_uso tbs_size tbs_maxsize free_space space on report

select /*+ RULE */ d.tablespace,
       CASE a.autoextensible WHEN 'YES' 
       THEN 'YES' 
       ELSE 'NO'
       end as autoextensible,
       b.bigfile,
       f.tbs_files,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) tbs_em_uso,
       trunc(d.tbs_size/1024/1024) tbs_size,
       trunc(d.tbs_maxsize/1024/1024) tbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) free_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) space,
       trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize) perc
from
  ( select /*+ RULE */ SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select /*+ RULE */ nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select /*+ RULE */ SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s,
  (
    SELECT  COUNT (*) tbs_files, tablespace_name tablespace
    FROM dba_data_files
    GROUP BY tablespace_name
  ) f,
  (
    SELECT DISTINCT tablespace_name tablespace, autoextensible
    FROM dba_data_files
    WHERE autoextensible = 'YES'
  ) a,
  (
    SELECT DISTINCT tablespace_name tablespace, bigfile
    FROM dba_tablespaces
  ) b
where d.tablespace = s.tablespace(+)
and   d.tablespace = f.tablespace(+)
and   d.tablespace = a.tablespace(+)
and   d.tablespace = b.tablespace(+)
order by 10 desc
/
set verify on
--
-- Fim
--

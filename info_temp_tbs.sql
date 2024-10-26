-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : info_temp_tbs.sql                                                                          --
-- Description   : Displays info of Tablespace.                                                          --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the DBA views.                                                              --
-- Call Syntax   : @info_tbs <TBS_NAME>                                                                  --
-- Last Modified : 07/07/2023                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

set lines 9999 
set pages 9999 
set verify off
col value for a10;
prompt *  INFO tablesapce  *
ACCEPT b PROMPT "Enter tablespace_name: "

column value new_val blksize
select value from v$parameter where name = 'db_block_size'
/

prompt 
prompt 

COL TABLESPACE   FOR A35          HEADING 'Tablespace'
COL TBS_SIZE     FOR 999,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL TBS_EM_USO   FOR 999,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL TBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL FREE_SPACE   FOR 999,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL SPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL PERC         FOR 990          HEADING '%|Ocupacao'          JUSTIFY RIGHT
--set wrap off
set lines 145
set pages 999
set verify off

break on report on tablespace_name skip 1
compute sum label "Total: " of tbs_em_uso tbs_size tbs_maxsize free_space space on report

select /*+ RULE */ d.tablespace,
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
  ) s
where d.tablespace = s.tablespace(+)
and d.tablespace = '&b'
order by 7 desc
/
prompt 
prompt

col file_name for a70
COL INCREMENT_MB FOR 999,999,990  HEADING 'GB|INCREMENT' JUSTIFY RIGHT
COL QTDE_EXTENSIONS FOR 999,999,990  HEADING 'QTDE|EXTENSIONS' JUSTIFY RIGHT
break on report on file_id skip 1
COMPUTE SUM LABEL "Total: " OF size_MB maxsize_MB ON REPORT
select file_id,
       file_name, 
       AUTOEXTENSIBLE, 
       (increment_by*(bytes/blocks)/1024/1024) "INCREMENT_MB",
       --(maxbytes-bytes)/(increment_by*(bytes/blocks)) "QTDE_EXTENSIONS",
       ceil(bytes / 1024 / 1024) size_MB, 
       ceil(maxbytes / 1024 / 1024) maxsize_MB
from   dba_temp_files
where  tablespace_name like '&&b'
order by 1 desc
/
prompt 
prompt 

select file_name,
       ceil( (nvl(hwm,1)*8192)/1024/1024 ) smallest,
       ceil( blocks*8192/1024/1024) currsize,
       ceil( blocks*8192/1024/1024) -
       ceil( (nvl(hwm,1)*8192)/1024/1024 ) savings,
	   AUTOEXTENSIBLE
from dba_temp_files a,
     ( select file_id, max(block_id+blocks-1) hwm
         from dba_extents
        group by file_id ) b
where a.file_id = b.file_id(+)
and tablespace_name = '&&b'
/
prompt 
prompt 

--column cmd format a150 word_wrapped
--select 'alter database datafile '''||file_name||''' resize ' ||
--       ceil( (nvl(hwm,1)*&&blksize)/1024/1024 )  || 'm;' cmd
--from dba_data_files a,
--     ( select file_id, max(block_id+blocks-1) hwm
--         from dba_extents
--        group by file_id ) b
--where a.file_id = b.file_id(+)
--  and ceil( blocks*&&blksize/1024/1024) -
--      ceil( (nvl(hwm,1)*&&blksize)/1024/1024 ) > 0
--and tablespace_name = '&&b'
--/
--set verify on

@asm
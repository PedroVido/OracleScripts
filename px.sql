-- ########################################################################################################
--                                                                                                       -- 
-- File Name     : px.sql                                                                                --
-- Description   : Show parallel session datails.                                                        --
-- Comments      : N/A                                                                                   --
-- Requirements  : Access to the V$ views.                                                               --
-- Call Syntax   : @px                                                                                   --
-- Last Modified : 16/09/2024                                                                            --
-- Author        : Pedro Vido - https://pedrovidodba.blogspot.com                                        --
--                                                                                                       --
-- ########################################################################################################

set lines 999
set pages 999

col username     for a20
col sid          for a8
col sql_id       for a15
col QC_SID       heading "QC|SID"      for a7
col QC_SERIAL    heading "QC|SERIAL"   for a7
col slave_set    heading "Slave Set"   for a10
col QC_Slave     heading "QC/Slave"    for a10
col QC_INST      heading "QC|INST"     for a5

select
     s.inst_id,
     decode(px.qcinst_id,NULL,s.username,' - '||lower(substr(s.program,length(s.program)-4,4) ) ) Username,
     decode(px.qcinst_id,NULL, 'QC', '(Slave)') QC_Slave ,
     to_char( px.server_set) slave_set,
     to_char(s.sid) "SID",
     decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) QC_SID,
     decode(px.qcserial#, NULL ,to_char(s.serial#) ,px.qcserial#) QC_SERIAL,
     decode(px.qcinst_id, NULL ,to_char(s.inst_id) ,px.qcinst_id) QC_INST,
     s.sql_id,
     s.machine,
     px.req_degree "Requested DOP",
     px.degree "Actual DOP"
from
gv$px_session px,
gv$session s, gv$process p
where
px.sid=s.sid (+) and
px.serial#=s.serial# and
px.inst_id = s.inst_id
and p.inst_id = s.inst_id
and p.addr=s.paddr
order by 6 , 1 desc
/
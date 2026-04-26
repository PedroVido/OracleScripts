col JOB_NAME for a30 word_wrap trunc
col PROGRAM_NAME for a30 word_wrap trunc
--col start_date for a50 word_wrap trunc
col NEXT_RUN_DATE for a50 word_wrap trunc
col LAST_START_DATE for a15 word_wrap trunc
col last_run_duration for a17 word_wrap trunc
col COMMENTS for a40 word_wrap trunc
col OWNER for a10 word_wrap trunc
select OWNER,JOB_NAME, PROGRAM_NAME,STATE, /*START_DATE,*/LAST_START_DATE, NEXT_RUN_DATE, last_run_duration,RUN_COUNT,JOB_WEIGHT, ENABLED, COMMENTS 
from dba_scheduler_jobs where enabled = 'TRUE' order by 6,7 desc;


-- 


SELECT 
    JOB_NAME,
    REPEAT_INTERVAL,
    LAST_START_DATE,
    STATE,
    LAST_RUN_DURATION,
    JOB_TYPE,
    PROGRAM_NAME,
    JOB_ACTION,
    JOB_PRIORITY,
    RUN_COUNT,
    MAX_RUNS,
    FAILURE_COUNT
FROM USER_SCHEDULER_JOBS;

--

SELECT to_char(log_date, 'DD-MON-YY HH24:MM:SS') TIMESTAMP, job_name, status,
   SUBSTR(additional_info, 1, 40) ADDITIONAL_INFO
   FROM user_scheduler_job_run_details ORDER BY log_date;

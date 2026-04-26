BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'MONITOR_ROW_CACHE_LOCK',
        job_type        => 'PLSQL_BLOCK',
        job_action      => q'[
            DECLARE
                -- (Cole aqui o bloco PL/SQL acima)
            END;
        ]',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
        enabled         => TRUE
    );
END;
/


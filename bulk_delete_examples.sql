BEGIN
  LOOP
    DELETE FROM your_table
    WHERE condition
    AND ROWNUM <= 1000; -- Delete in batches of 1000 rows
    EXIT WHEN SQL%ROWCOUNT = 0;
    COMMIT;
  END LOOP;
END;

-----


DECLARE
  v_rows_deleted NUMBER;
BEGIN
  LOOP
    DELETE FROM your_table
    WHERE condition
    AND ROWNUM <= 1000; -- Delete in batches of 1000 rows

    v_rows_deleted := SQL%ROWCOUNT;

    COMMIT; -- Commit after each batch

    EXIT WHEN v_rows_deleted = 0; -- Exit when no more rows to delete
  END LOOP;
END;
/
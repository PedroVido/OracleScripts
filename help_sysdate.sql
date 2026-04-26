In Oracle SQL, the SYSDATE function returns the current date and time from the database server.

When you do:

--============================
SYSDATE - 1/24
--============================
it means:

1 represents 1 day in Oracles date arithmetic.
1/24 is one hour (since there are 24 hours in a day).
Subtracting it from SYSDATE moves the timestamp one hour earlier.

Example:
If the current SYSDATE is:
05-FEB-2026 15:30:00

then:

SELECT SYSDATE AS now,
       SYSDATE - 1/24 AS one_hour_ago
FROM dual;


would return:

NOW                  ONE_HOUR_AGO
-------------------  -------------------
05-FEB-2026 15:30:00 05-FEB-2026 14:30:00

--============================
✅ General rule:
--============================

SYSDATE - N → subtracts N days.
SYSDATE - (N/24) → subtracts N hours.
SYSDATE - (N/(24*60)) → subtracts N minutes.
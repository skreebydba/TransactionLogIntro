USE msdb;

DECLARE @TodayInt INT = CAST(CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,112) AS INT);

SELECT h.step_name, h.run_date, h.run_time,
CONCAT(RIGHT('0' + RTRIM((h.run_duration)/100), 2), ':' , RIGHT('0' + RTRIM((h.run_duration)%100), 2)) AS [RunDuration]
 FROM sysjobhistory h
INNER JOIN sysjobs j
ON j.job_id = h.job_id
WHERE j.name = 'InsertRowsToTestTables'
AND h.run_date = @TodayInt
AND h.run_time >=
	(SELECT MAX(run_time)
	 FROM sysjobhistory h1
	 INNER JOIN sysjobs j1
	 ON j1.job_id = h1.job_id
	 WHERE j1.name = 'InsertRowsToTestTables' 
	 AND h1.step_id = 1
	 AND run_date = @TodayInt)
AND h.step_id > 0
ORDER BY step_id;


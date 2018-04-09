USE master
GO

DROP TABLE IF EXISTS #transactions;
 
-- Create a temp table to hold the result set from sys.dm_tran_database_transactions
 
CREATE TABLE #transactions
(tranid BIGINT
,databaseid INT
,trantype INT
,transtate INT
,recordcount INT
,bytesused BIGINT
,bytesreserved BIGINT)
 
-- Run an infinite loop for the duration of each update script
-- stopping it when the script completes
 
WHILE 1 = 1
BEGIN
 
    INSERT INTO #transactions
    SELECT transaction_id AS [Tran ID], 
    database_id AS [Database ID], 
    database_transaction_type AS [Tran Type], 
    database_transaction_state AS [Tran State], 
    database_transaction_log_record_count AS [Log Record Count],
    database_transaction_log_bytes_used AS [Log Bytes Used],
    database_transaction_log_bytes_reserved AS [Log Bytes Reserved]
    FROM sys.dm_tran_database_transactions
 
END
 
-- Use the select statement below to see the results
-- This query will return a single row per transaction
-- for read/write activity (trantype = 1)
-- that has generated log records (transtate = 4)
 
SELECT tranid, 
MAX(recordcount) AS [Record Count], 
(MAX(bytesused)/1045876) AS [MB Used], 
(MAX(bytesreserved)/1045876) AS [MB Reserved] 
FROM #transactions
WHERE databaseid = DB_ID('OneTran')  -- Make sure to use the correct database name
AND trantype = 1
AND transtate = 4
GROUP BY tranid

SELECT tranid, 
MAX(recordcount) AS [Record Count], 
(MAX(bytesused)/1045876) AS [MB Used], 
(MAX(bytesreserved)/1045876) AS [MB Reserved] 
FROM #transactions
WHERE databaseid = DB_ID('LoopTran')  -- Make sure to use the correct database name
AND trantype = 1
AND transtate = 4
GROUP BY tranid
 
-- Clean up the temp table after the run
 
--DROP TABLE #transactions
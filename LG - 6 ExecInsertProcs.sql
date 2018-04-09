USE SmallLog;

DBCC TRACEON(3004,3605,-1);

DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @seconds INT;
--DECLARE @mmss NVARCHAR(5);

SELECT @starttime = CURRENT_TIMESTAMP;

EXEC InsertSmallLogTable;

SELECT @endtime = CURRENT_TIMESTAMP;

SELECT @seconds = DATEDIFF(SECOND,@starttime,@endtime);
SELECT CONCAT(RIGHT('0' + RTRIM(CAST((@seconds / 60) AS NVARCHAR(2))),2),':',RIGHT('0' + RTRIM(CAST((@seconds % 60) AS NVARCHAR(2))),2)) AS [Small Log Insert Duration];

USE BigLog;

SELECT @starttime = CURRENT_TIMESTAMP;

EXEC InsertBigLogTable;

SELECT @endtime  = CURRENT_TIMESTAMP;

SELECT @seconds = DATEDIFF(SECOND,@starttime,@endtime);

SELECT CONCAT(RIGHT('0' + RTRIM(CAST((@seconds / 60) AS NVARCHAR(2))),2),':',RIGHT('0' + RTRIM(CAST((@seconds % 60) AS NVARCHAR(2))),2)) AS [Big Log Insert Duration];
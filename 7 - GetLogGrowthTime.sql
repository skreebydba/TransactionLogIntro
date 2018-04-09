USE master;

DROP TABLE IF EXISTS #ErrorLog;
DROP TABLE IF EXISTS #LogGrowthDuration;

CREATE TABLE #ErrorLog
(LogDate DATETIME
,ProcessInfo VARCHAR(20)
,ErrorText VARCHAR(2000));

CREATE TABLE #LogGrowthDuration
(DBName SYSNAME
,LogGrowthMs INT);

INSERT INTO #ErrorLog
(LogDate
,ProcessInfo
,ErrorText)
EXEC xp_readerrorlog 0, 1;

INSERT INTO #LogGrowthDuration
(DBName
,LogGrowthMs)
SELECT 'SmallLog' AS DBName, SUM(CAST(SUBSTRING(ErrorText, PATINDEX('% = [0-9]%', ErrorText) + 2,(PATINDEX('% ms%', ErrorText) - PATINDEX('%=%',ErrorText))) AS INT)) AS [SmallLogGrowth (ms)]
FROM #ErrorLog
WHERE ErrorText LIKE '%Zeroing completed%SmallLog%';

INSERT INTO #LogGrowthDuration
(DBName
,LogGrowthMs)
SELECT 'BigLog' AS DBName, SUM(CAST(SUBSTRING(ErrorText, PATINDEX('% = [0-9]%', ErrorText) + 2,(PATINDEX('% ms%', ErrorText) - PATINDEX('%=%',ErrorText))) AS INT))  AS [BigLogGrowth (ms)]
FROM #ErrorLog
WHERE ErrorText LIKE '%Zeroing completed%BigLog%';

SELECT * FROM #LogGrowthDuration;
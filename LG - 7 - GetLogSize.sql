USE master;

--DROP TABLE IF EXISTS #LogSize;
--DROP TABLE IF EXISTS #TableSize;	
--DROP TABLE IF EXISTS #DbccLogInfo;
--DROP TABLE IF EXISTS #ErrorLog;
--DROP TABLE IF EXISTS #LogGrowthDuration;

IF OBJECT_ID('tempdb.dbo.#LogSize') IS NOT NULL
BEGIN

	DROP TABLE #LogSize;

END

IF OBJECT_ID('tempdb.dbo.#TableSize') IS NOT NULL
BEGIN

	DROP TABLE #TableSize;

END

IF OBJECT_ID('tempdb.dbo.#DbccLogInfo') IS NOT NULL
BEGIN

	DROP TABLE #DbccLogInfo;

END

IF OBJECT_ID('tempdb.dbo.#ErrorLog') IS NOT NULL
BEGIN

	DROP TABLE #ErrorLog;

END

IF OBJECT_ID('tempdb.dbo.#LogGrowthDuration') IS NOT NULL
BEGIN

	DROP TABLE #LogGrowthDuration;

END

DECLARE @loginfo NVARCHAR(100);

SELECT @loginfo = N'DBCC LOGINFO()';

CREATE TABLE #LogSize
(DBName SYSNAME
,[FileName] SYSNAME
,[LogFileSize (mb)] INT);

CREATE TABLE #TableSize
(DBName SYSNAME NULL DEFAULT DB_NAME()
,TableName SYSNAME
,TableRows BIGINT
,ReservedSpace VARCHAR(30)
,DataSpace VARCHAR(30)
,IndexSpace VARCHAR(30)
,UnusedSpace VARCHAR(30));

CREATE TABLE #DbccLogInfo
(
ServerName SYSNAME NULL DEFAULT @@servername,
DBName SYSNAME NULL DEFAULT DB_NAME(),
RecoveryUnitID INT,
FileId INT NOT NULL,
FileSize BIGINT,
StartOffset BIGINT,
FSeqNo INT,
[Status] TINYINT,
Parity INT,
CreateLSN NUMERIC(25,0));

CREATE TABLE #ErrorLog
(LogDate DATETIME
,ProcessInfo VARCHAR(20)
,ErrorText VARCHAR(2000));

CREATE TABLE #LogGrowthDuration
(DBName SYSNAME
,LogGrowthMs INT);

INSERT INTO #LogSize
SELECT DB_NAME(database_id), [name], (size * 8) / 1024 AS [SmallLog FileSize (mb)]
FROM sys.master_files
WHERE database_id = DB_ID('SmallLog')
AND [type] = 1;

INSERT INTO #LogSize
SELECT DB_NAME(database_id), [name], (size * 8) / 1024 AS [BigLog FileSize (mb)]
FROM sys.master_files
WHERE database_id = DB_ID('BigLog')
AND [type] = 1;

USE BigLog;
INSERT INTO #TableSize
(TableName
,TableRows
,ReservedSpace
,DataSpace
,IndexSpace
,UnusedSpace)
EXEC sp_spaceused TestTable;

USE SmallLog;
INSERT INTO #TableSize
(TableName
,TableRows
,ReservedSpace
,DataSpace
,IndexSpace
,UnusedSpace)
EXEC sp_spaceused TestTable;

USE BigLog;

INSERT INTO #DbccLogInfo
(RecoveryUnitID
,FileId
,FileSize
,StartOffset
,FSeqNo
,[Status]
,Parity
,CreateLSN)
EXEC sp_executesql @loginfo;

USE SmallLog;

INSERT INTO #DbccLogInfo
(RecoveryUnitID
,FileId
,FileSize
,StartOffset
,FSeqNo
,[Status]
,Parity
,CreateLSN)
EXEC sp_executesql @loginfo;

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

WITH LogInfo AS 
(
SELECT DBName, [Status] AS VlfStatus, AVG(FileSize) AS AvgVlfSize, COUNT(*) AS VlfCount
FROM #DbccLogInfo
GROUP BY DBName, [Status]
)


SELECT li.DBName, 
li.VlfStatus, 
li.VlfCount, 
(li.AvgVlfSize / 1045876) AS [AvgVlfSize (mb)],
fs.TableName,
fs.TableRows,
fs.ReservedSpace,
fs.DataSpace,
ls.[LogFileSize (mb)],
COALESCE(lg.LogGrowthMs,0) AS [LogGrowth (ms)]
FROM LogInfo AS li
INNER JOIN #TableSize AS fs
	ON fs.DBName = li.DBName
INNER JOIN #LogSize AS ls
	ON ls.DBName = li.DBName
INNER JOIN #LogGrowthDuration AS lg
	ON lg.DBName = li.DBName
ORDER BY DBName, VlfStatus;



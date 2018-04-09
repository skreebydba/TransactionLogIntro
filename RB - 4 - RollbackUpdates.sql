USE OneTran;

DROP TABLE IF EXISTS #rollbackinfo;

CREATE TABLE #rollbackinfo
(Operation NVARCHAR(62)
,Context NVARCHAR(512)
,[Description] NVARCHAR(512)
,AllocUnitName NVARCHAR(774)
,TotalReserved INT
,TotalOperations INT)

DECLARE @maxlsn NVARCHAR(46);

SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);

BEGIN TRANSACTION
	
	UPDATE RollBackTable
	SET TextField = REPLICATE('x',1000);
	--WHERE RowId % 2 = 0;

ROLLBACK TRANSACTION

INSERT INTO #rollbackinfo
(Operation
,Context
,[Description]
,AllocUnitName
,TotalReserved
,TotalOperations)
SELECT Operation, Context, [Description], AllocUnitName, SUM([Log Reserve]) AS [Total Reserved], COUNT(*) AS [Total Operations]
FROM fn_dblog(@maxlsn,NULL)
WHERE Operation IN ('LOP_INSERT_ROWS', 'LOP_DELETE_ROWS', 'LOP_MODIFY_ROW')
AND AllocUnitName = 'dbo.RollBackTable.IX_RollBackTable_RowId'
GROUP BY Operation, Context, [Description], AllocUnitName;

SELECT * FROM #rollbackinfo;

--SELECT (CAST(SUM([TotalReserved]) AS DECIMAL(14,4)/CAST(MAX([TotalReserved] AS DECIMAL(14,4)))))
SELECT ROUND((CAST(SUM(TotalReserved) AS DECIMAL(14,4))/CAST(MAX(TotalReserved) AS DECIMAL(14,4)) * 100),0)
FROM #rollbackinfo;

SELECT [Current LSN]
,[Transaction ID]
,[Transaction Name]
,Operation
,Context
,[Log Reserve]
,[Description]
,[Previous LSN]
,AllocUnitName
,[Page ID]
,[Slot ID]
,[Begin Time]
,[Database Name]
,[Number of Locks]
,[Lock Information]
,[New Split Page]
FROM fn_dblog(@maxlsn,NULL)
WHERE Operation IN ('LOP_INSERT_ROWS', 'LOP_DELETE_ROWS', 'LOP_MODIFY_ROW')
AND AllocUnitName = 'dbo.RollBackTable.IX_RollBackTable_RowId';
--GROUP BY Operation, [Description], AllocUnitName;


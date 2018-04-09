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
DECLARE @loopcount INT = 1;
DECLARE @looplimit INT = 1000;

SELECT @maxlsn = CONCAT(N'0x',MAX([Current LSN])) FROM fn_dblog(NULL,NULL);
SELECT @maxlsn;

BEGIN TRANSACTION
	
	WHILE @loopcount <= @looplimit
	BEGIN

		INSERT INTO RollBackTable
		VALUES
		(REPLICATE('1',1000));
		SELECT @loopcount += 1;

	END

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
WHERE Operation IN ('LOP_INSERT_ROWS', 'LOP_DELETE_ROWS', 'LOP_MODIFY_ROW', 'LOP_SET_BITS')
AND AllocUnitName = 'dbo.RollBackTable.IX_RollBackTable_RowId'
GROUP BY Operation, Context, [Description], AllocUnitName;

SELECT * FROM #rollbackinfo
ORDER BY TotalOperations DESC;	

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
WHERE Operation IN ('LOP_INSERT_ROWS', 'LOP_DELETE_ROWS', 'LOP_MODIFY_ROW', 'LOP_SET_BITS')
AND AllocUnitName = 'dbo.RollBackTable.IX_RollBackTable_RowId';


SELECT * FROM fn_dblog(@maxlsn,NULL)
WHERE AllocUnitName = 'dbo.RollBackTable.IX_RollBackTable_RowId'
AND Operation IN ('LOP_INSERT_ROWS', 'LOP_DELETE_ROWS', 'LOP_MODIFY_ROW', 'LOP_SET_BITS');
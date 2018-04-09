USE SmallLog;

IF OBJECT_ID('SmallLog.dbo.TestTable') IS NOT NULL
BEGIN

	DROP TABLE TestTable;

END

CREATE TABLE TestTable
(RowID INT IDENTITY(1,1)
,FirstName NVARCHAR(50)
,LastName NVARCHAR(50)
,Comments NVARCHAR(1000));

CREATE UNIQUE CLUSTERED INDEX IX_TestTable_RowID ON TestTable(RowID);

USE BigLog;

IF OBJECT_ID('BigLog.dbo.TestTable') IS NOT NULL
BEGIN

	DROP TABLE TestTable;

END

CREATE TABLE TestTable
(RowID INT IDENTITY(1,1)
,FirstName NVARCHAR(50)
,LastName NVARCHAR(50)
,Comments NVARCHAR(1000));

CREATE UNIQUE CLUSTERED INDEX IX_TestTable_RowID ON TestTable(RowID);
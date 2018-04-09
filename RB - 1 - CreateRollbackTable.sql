USE OneTran;

SET NOCOUNT ON;

DROP TABLE IF EXISTS RollBackTable;

CREATE TABLE RollBackTable
(RowId INT IDENTITY(1,1)
,TextField VARCHAR(1000));

CREATE UNIQUE CLUSTERED INDEX IX_RollBackTable_RowId ON RollBackTable(RowID);

DECLARE @loopcount INT = 1;
DECLARE @looplimit INT = 1000;

WHILE @loopcount <= @looplimit
BEGIN

	INSERT INTO RollBackTable
	(TextField)
	VALUES
	(REPLICATE('a',1000));
	
	SELECT @loopcount += 1;

END

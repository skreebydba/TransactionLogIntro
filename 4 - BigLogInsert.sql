USE master;

SET NOCOUNT ON;

DECLARE @loopcount INT = 1;
DECLARE @looplimit INT = 1000000;

WHILE @loopcount <= @looplimit
BEGIN

	INSERT INTO BigLog.dbo.TestTable
	(FirstName
	,LastName
	,Comments)
	VALUES
	('Steve'
	,'Jones'
	,REPLICATE('This is a comment', 58));

	SELECT @loopcount += 1;

END
USE SmallLog;
-- =============================================
-- Create basic stored procedure template
-- =============================================

-- Drop stored procedure if it already exists
IF EXISTS (
  SELECT * 
    FROM INFORMATION_SCHEMA.ROUTINES 
   WHERE SPECIFIC_SCHEMA = N'dbo'
     AND SPECIFIC_NAME = N'InsertSmallLogTable' 
)
   DROP PROCEDURE dbo.InsertSmallLogTable
GO

CREATE PROCEDURE dbo.InsertSmallLogTable
	@NumberOfRows INT = 100000
AS
SET NOCOUNT ON;

DECLARE @loopcount INT;

SELECT @loopcount = 1;
WHILE @loopcount <= @NumberOfRows
BEGIN

	INSERT INTO SmallLog.dbo.TestTable
	(FirstName
	,LastName
	,Comments)
	VALUES
	('Steve'
	,'Jones'
	,REPLICATE('This is a comment', 58));

	SELECT @loopcount += 1;

END
GO



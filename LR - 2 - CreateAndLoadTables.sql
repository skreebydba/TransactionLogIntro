USE LoopTran
GO

SET NOCOUNT ON;
-- Create an populate a table in each database to use in the update loops
 
CREATE TABLE LoopTable
(runnumber INT
,rundate DATETIME
,vartext VARCHAR(10)
,chartext CHAR(10))
 
USE OneTran
GO
 
CREATE TABLE OneTable
(runnumber INT
,rundate DATETIME
,vartext VARCHAR(10)
,chartext CHAR(10))
 
USE LoopTran
GO
 
INSERT INTO LoopTable
VALUES
(1
,GETDATE()
,REPLICATE('a',10)
,REPLICATE('b',10))
GO 100000
 
USE OneTran
GO
 
INSERT INTO OneTable
VALUES
(1
,GETDATE()
,REPLICATE('a',10)
,REPLICATE('b',10))
GO 100000
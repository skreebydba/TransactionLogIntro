USE OneTran
GO
 
-- Declare @loopcount variable to run the loop
-- Declare @textlen to vary the length of the text fields
 
DECLARE @loopcount INT
DECLARE @textlen TINYINT
SET @loopcount = 1
 
-- Begin an explicit transaction that will remain open for the duration of the loop
BEGIN TRAN
 
WHILE @loopcount <= 10
BEGIN
 
    -- Use the modulus operator to set text length to the remainder of @loopcount / 10
 
    SET @textlen = (@loopcount % 10)
     
    -- Update onetranu using the values described below
    UPDATE OneTable
    -- Set runnumber equal to @loopcount
    SET runnumber = @loopcount, 
    -- Set rundate equal the current datetime
    rundate = GETDATE(), 
    -- Set vartext to a string of a's, with the length determined by the @textlen variable
    vartext = REPLICATE('a',@textlen), 
    -- Set chartext to a string of b's, with the length determined by the @textlen variable
    chartext = REPLICATE('b',@textlen)
 
    -- Increment @loopcount
    SET @loopcount = @loopcount + 1
 
END
 
COMMIT
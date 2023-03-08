/*
Zero Downtime Demos

Rename a column and rename a table

Deployment 2 - Remove the copy and rename the original

Copyright 2022 Steve Jones
*/

-- start a transaction
BEGIN TRAN

-- remove the computed column
ALTER TABLE dbo.OrderHeader DROP COLUMN OrderedByDate

IF @@ERROR <> 0
	ROLLBACK

-- rename the original
EXEC sp_rename @objname = 'dbo.OrderHeader.OrderDate' ,
@newname = 'OrderedByDate' ,
@objtype = 'column';
GO

IF @@ERROR <> 0
	ROLLBACK
ELSE
	COMMIT
GO
ALTER PROCEDURE dbo.GetOrder
	@OrderID INT 
AS
SELECT o.OrderID
     , o.CustomerID
     , o.OrderedByDate
     , o.ShipDate
     , c.CustomerID
     , c.CustomerName
     , c.CustomerAddress
     , c.City
     , c.St
     , c.zip
     , c.FirstName
     , c.LastName
 FROM dbo.OrderHeader AS o
 INNER JOIN  dbo.Customer AS c ON c.CustomerID = o.CustomerID
 where o.OrderID = @orderID
GO
ALTER PROCEDURE dbo.AddNewOrder
AS
BEGIN
    DECLARE @orderid INT
	, @custid int
	, @orderdate DATETIME
	, @shipdate datetime
	SELECT TOP 1 @custid = c.CustomerID FROM dbo.Customer AS c ORDER BY NEWID()
	SELECT @orderdate = DATEADD( DAY, ABS(CHECKSUM(NEWID())) / 1000000, '2020-01-01')
	SELECT @shipdate = DATEADD( DAY, ABS(CHECKSUM(NEWID())) / 1000000, '2020-02-01')
	INSERT dbo.OrderHeader
	  (CustomerID, OrderedByDate, ShipDate)
	VALUES
	  (@custid, @orderdate, @shipdate)
	SELECT @orderid = SCOPE_IDENTITY()
	SELECT @orderid AS OrderID, @custid AS CustomerID, @orderdate AS OrderedByDate, @shipdate AS ShipDate
END
GO






-- cleanup if needed
/*
EXEC sp_rename @objname = 'dbo.OrderHeader.OrderedbyDate' ,
@newname = 'OrderDate' ,
@objtype = 'column';
GO
*/

-- cleanup for testing
--ALTER TABLE dbo.OrderHeader DROP COLUMN OrderedBy

-- NAME:XIAOXIAO CAO
-- ID:103043833
--  https://www.red-gate.com/simple-talk/sql/t-sql-programming/questions-about-t-sql-transaction-isolation-levels-you-were-too-shy-to-ask/
IF OBJECT_ID('EmployeeInfo') IS NOT NULL DROP TABLE EmployeeInfo;

CREATE TABLE EmployeeInfo

(

EmpID int PRIMARY KEY IDENTITY(1,1),

FirstName varchar(255),

LastName varchar(255),

)

INSERT INTO EmployeeInfo

Values

('Bob', 'Builder'),

('Tim', 'Trader'),

('Yuri', 'Trainer'),

('Tom ', 'Tanker');

-- session 1
-- BEGIN TRANSACTION; 
 
-- UPDATE EmployeeInfo
-- SET FirstName = 'JACK'
-- WHERE EmpID = 4;
 
-- WAITFOR DELAY '00:00:10'  
 
-- ROLLBACK TRANSACTION;

--session 1
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
 
-- BEGIN TRANSACTION;
 
-- SELECT FirstName FROM EmployeeInfo
-- WHERE EmpID = 1;
 
-- WAITFOR DELAY '00:00:05'  
 
-- SELECT FirstName FROM EmployeeInfo
-- WHERE EmpID = 1;
 
-- ROLLBACK TRANSACTION;

--session 1 SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
 
-- BEGIN TRANSACTION;
 
-- SELECT FirstName FROM EmployeeInfo
-- WHERE EmpID = 2;
 
-- WAITFOR DELAY '00:00:05'  
 
-- SELECT FirstName FROM EmployeeInfo
-- WHERE EmpID = 2;
 
-- ROLLBACK TRANSACTION;

-- ALTER DATABASE AdventureWorks2014 
-- SET READ_COMMITTED_SNAPSHOT ON;
-- ALTER DATABASE AdventureWorks2014 
-- SET READ_COMMITTED_SNAPSHOT ON;
 
-- ALTER DATABASE AdventureWorks2014 
-- SET ALLOW_SNAPSHOT_ISOLATION ON;
 
-- ALTER DATABASE AdventureWorks2014 
-- SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT ON;
-- ////////////////////////must use the SET TRANSACTION ISOLATION LEVEL statement at the session level,
--  ------------------------or use a table hint at the statement level, to apply only to that statement. USE TABLOCK
-- ---------------------------The table hint will apply only to the table targeted in this statement and will not impact the rest of the session,
SELECT EmpID, FirstName, LastName 
FROM EmployeeInfo WITH(TABLOCK)
WHERE EmpID > 99
ORDER BY LastName;
-- -----------------------------------se table hints for a specific table in a join-----------------------------------
-- SELECT d.ProductID, d.OrderQty, h.OrderDate
-- FROM Sales.SalesOrderHeader h INNER JOIN 
--   Sales.SalesOrderDetail d WITH(SERIALIZABLE)
--   ON h.SalesOrderID = d.SalesOrderID
-- ORDER BY d.ProductID, h.OrderDate DESC;
-- NOTE The Read Committed isolation level (the default) still applies to the SalesOrderHeader table

-- When you enable the ALLOW_SNAPSHOT_ISOLATION option, you activate a mechanism in your database for storing the versioned rows in tempdb.--------------
ALTER DATABASE Xiaoxiao 
SET ALLOW_SNAPSHOT_ISOLATION ON;

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
 
BEGIN TRANSACTION;
 
SELECT FirstName FROM EmployeeInfo
WHERE EmpID = 1;
 
COMMIT TRANSACTION;


--session 1
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 
BEGIN TRANSACTION;
 
SELECT FirstName FROM EmployeeInfo
WHERE EmpID = 1;
 
WAITFOR DELAY '00:00:10'  
 
UPDATE EmployeeInfo
SET FirstName = 'Roger'
WHERE EmpID = 1;
 
SELECT FirstName FROM EmployeeInfo
WHERE EmpID = 1;
 
COMMIT TRANSACTION;


-- ----------------------to know the setting for the ALLOW_SNAPSHOT_ISOLATION option,
SELECT snapshot_isolation_state_desc 
FROM sys.databases 
WHERE name = 'Xiaoxiao'

-- ----------------------get transaction isolation levels  --------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
SELECT FirstName FROM EmployeeInfo
WHERE EmpID = 1;

SELECT transaction_isolation_level
FROM sys.dm_exec_sessions
WHERE session_id = @@SPID;
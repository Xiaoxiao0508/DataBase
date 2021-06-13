--session 2
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
 
-- SELECT FirstName FROM EmployeeInfo
-- WHERE EmpID = 4;
--session 2
-- UPDATE EmployeeInfo
-- SET FirstName = 'Frank'
-- WHERE EmpID = 1;
--session 2
UPDATE EmployeeInfo
SET FirstName = 'Ken'
WHERE EmpID = 2;

--session 2
UPDATE EmployeeInfo
SET FirstName = 'Harold'
WHERE EmpID = 1;
 
SELECT FirstName FROM EmployeeInfo
WHERE EmpID = 1;
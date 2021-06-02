

-- NAME:XIAOXIAO CAO
-- ID:103043833
SELECT name FROM master.dbo.sysdatabases
use [db-xiaoxiao]
CREATE TABLE Person (
    PersonID int PRIMARY KEY IDENTITY(1,1),
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255),
	Age INT
)
 
GO
 
INSERT INTO Person VALUES('Hayes', 'Corey','123  Wern Ddu Lane','LUSTLEIGH',23)
INSERT INTO Person VALUES('Macdonald','Charlie','23  Peachfield Road','CEFN EINION',45)
INSERT INTO Person VALUES('Frost','Emma','85  Kingsway North','HOLTON',26)
INSERT INTO Person VALUES('Thomas', 'Tom','59  Dover Road', 'WESTER GRUINARDS',51)
INSERT INTO Person VALUES('Baxter','Cameron','106  Newmarket Road','HAWTHORPE',46)
INSERT INTO Person VALUES('Townsend','Imogen ','100  Shannon Way','CHIPPENHAM',20)
INSERT INTO Person VALUES('Preston','Taylor','14  Pendwyallt Road','BURTON',19)
INSERT INTO Person VALUES('Townsend','Imogen ','100  Shannon Way','CHIPPENHAM',18)
INSERT INTO Person VALUES('Khan','Jacob','72  Ballifeary Road','BANCFFOSFELEN',11)



-- -------------------------------------------------Define implicit transaction example-------------------------------------------------------------------------
-- ----------------------------------------------------Tip: @@TRANCOUNT function returns the number of BEGIN TRANSACTION statements in the current session 
-- ---------------------------------------------------- we can use this function to count the open local transaction numbers in the examples
-- ------------------------------------------------------In order to define an implicit transaction, we need to enable the IMPLICIT_TRANSACTIONS option.
SET IMPLICIT_TRANSACTIONS ON 
UPDATE 
    Person 
SET 
    Lastname = 'Sawyer', 
    Firstname = 'Tom' 
WHERE 
    PersonID = 2 
SELECT 


    IIF(@@OPTIONS & 2 = 2, 
    'Implicit Transaction Mode ON', 
    'Implicit Transaction Mode OFF'
    ) AS 'Transaction Mode' 
SELECT 
    @@TRANCOUNT AS OpenTransactions 
COMMIT TRAN 
SELECT 
    @@TRANCOUNT AS OpenTransactions
-- -------------------------------------------------Define explicit transaction example--------------------------------------------------------------------------
--------------------------------------- ----------------we start to use the BEGIN TRANSACTION command, and use COMMIT TRAN to make the data change permanent


BEGIN TRAN
UPDATE Person 
SET    Lastname = 'Lucky', 
        Firstname = 'Luke' 
WHERE  PersonID = 1
SELECT @@TRANCOUNT AS OpenTransactions 
COMMIT TRAN 
SELECT @@TRANCOUNT AS OpenTransactions


-- --------------------------------------------- ROLLBACK TRANSACTION ------------------------------------------------------------------------------------------
--------------------------------------------------- helps in undoing all data modifications that are applied by the transaction. 
-- ---------------------------------------------------In the  example, we will change a particular row but this data modification will not persist.
BEGIN TRAN
UPDATE Person 
SET    Lastname = 'Donald', 
        Firstname = 'Duck'  WHERE PersonID=2
 
 
SELECT * FROM Person WHERE PersonID=2
 
ROLLBACK TRAN 
 
SELECT * FROM Person WHERE PersonID=2
-- ---------------------------------------------------SAVE Point-------------------------------------------------------------------------------------------------
-- ------------------------------------------------------SAVE TRANSACTION syntax,give the save point a nmae,then roll back from there
BEGIN TRANSACTION 
INSERT INTO Person 
VALUES('Mouse', 'Micky','500 South Buena Vista Street, Burbank','California',43)
SAVE TRANSACTION InsertStatement
DELETE Person WHERE PersonID=3
SELECT * FROM Person 
ROLLBACK TRANSACTION InsertStatement
COMMIT
SELECT * FROM Person
-- ----------------------------------------------------Auto Rollback--------------------------------------------------------------------------------------------
-- --------------------------------------------------------if one of the SQL statements returns an error all modifications are erased, 
----------------------------------------------------------- and the remaining statements are not executed
BEGIN TRAN
INSERT INTO Person 
VALUES('Bunny', 'Bugs','742 Evergreen Terrace','Springfield',54)
    
UPDATE Person SET Age='MiddleAge' WHERE PersonID=7
SELECT * FROM Person
 
COMMIT TRAN
-- --------------------------------------------------------Marked transactions------------------------------------------------------------------------------------
-------------------------------------------------------------give transaction a name and mark name
-- -------------------------------------------------------------the marked transaction will be stored with more detials for future use
-- ------------------------------------------------------------can be used for recovery point with options STRPATMARK or STOPBEFOREMARK
BEGIN TRAN DeletePerson WITH MARK 'MarkedTransactionDescription' 
    DELETE Person WHERE PersonID BETWEEN 3 AND 4
    
    COMMIT TRAN DeletePerson
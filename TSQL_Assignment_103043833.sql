use test;
IF OBJECT_ID('Sale') IS NOT NULL
DROP TABLE SALE;

IF OBJECT_ID('Product') IS NOT NULL
DROP TABLE PRODUCT;

IF OBJECT_ID('Customer') IS NOT NULL
DROP TABLE CUSTOMER;

IF OBJECT_ID('Location') IS NOT NULL
DROP TABLE LOCATION;

-- IF CURSOR_STATUS('global','POUTCUR')>=-1
-- BEGIN
--  DEALLOCATE POUTCUR
-- END
IF OBJECT_ID('GET_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE GET_ALL_PRODUCTS;

GO

CREATE TABLE CUSTOMER
(
    CUSTID INT
,
    CUSTNAME NVARCHAR(100)
,
    SALES_YTD MONEY
,
    STATUS NVARCHAR(7)
,
    PRIMARY KEY	(CUSTID)
);


CREATE TABLE PRODUCT
(
    PRODID INT
,
    PRODNAME NVARCHAR(100)
,
    SELLING_PRICE MONEY
,
    SALES_YTD MONEY
,
    PRIMARY KEY	(PRODID)
);

CREATE TABLE SALE
(
    SALEID BIGINT
,
    CUSTID INT
,
    PRODID INT
,
    QTY INT
,
    PRICE MONEY
,
    SALEDATE DATE
,
    PRIMARY KEY 	(SALEID)
,
    FOREIGN KEY 	(CUSTID) REFERENCES CUSTOMER
,
    FOREIGN KEY 	(PRODID) REFERENCES PRODUCT
);

CREATE TABLE LOCATION
(
    LOCID NVARCHAR(5)
,
    MINQTY INTEGER
,
    MAXQTY INTEGER
,
    PRIMARY KEY 	(LOCID)
,
    CONSTRAINT CHECK_LOCID_LENGTH CHECK (LEN(LOCID) = 5)
,
    CONSTRAINT CHECK_MINQTY_RANGE CHECK (MINQTY BETWEEN 0 AND 999)
,
    CONSTRAINT CHECK_MAXQTY_RANGE CHECK (MAXQTY BETWEEN 0 AND 999)
,
    CONSTRAINT CHECK_MAXQTY_GREATER_MIXQTY CHECK (MAXQTY >= MINQTY)
);


IF OBJECT_ID('SALE_SEQ') IS NOT NULL
DROP SEQUENCE SALE_SEQ;
CREATE SEQUENCE SALE_SEQ
AS BIGINT
START WITH 1
INCREMENT BY 1;

GO

-- ----------------------------task1----------------------------------
IF OBJECT_ID('ADD_CUSTOMER') IS NOT NULL
DROP PROCEDURE ADD_CUSTOMER;
GO
CREATE PROCEDURE ADD_CUSTOMER
    @pcustid INT,
    @pcustname nvarchar(100)
AS
BEGIN
    BEGIN TRY 
       IF @pcustid<1 or @pcustid>499
       THROW 50020,'CUSTOMER id out of range',1
        SELECT @pcustid=CUSTNAME
        FROM CUSTOMER
        IF @@ROWCOUNT!=0
            THROW 50030,'Duplicate customer ID',1
       INSERT INTO Customer(CUSTID,CUSTNAME,SALES_YTD,STATUS) VALUES
        (@pcustid, @pcustname, 0, 'ok')
    END TRY
    BEGIN CATCH
       IF ERROR_NUMBER()=2627
       THROW 50010,'Duplicate customer ID',1
       ELSE IF ERROR_NUMBER()=50020
       THROW
       ELSE
           BEGIN
              DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
              THROW 50000,@ERRORMESSAGE,1
           END;
    END CATCH;

END;
-- GO
-- EXEC  ADD_CUSTOMER @pcustid=123,@pcustname='DEFAULT'
-- SELECT *
-- FROM CUSTOMER

-- --------------------------TASK2--------------------------------------------
GO
IF OBJECT_ID('DELETE_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE DELETE_ALL_CUSTOMERS;
GO
CREATE PROCEDURE DELETE_ALL_CUSTOMERS AS
BEGIN
    BEGIN TRY
        DELETE
        FROM Customer
        PRINT (CONCAT('There are',@@ROWCOUNT,'rows affected'))
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()=50000
            BEGIN
              DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
              THROW 50000,@ERRORMESSAGE,1
            END;
    END CATCH;
END
-- GO
-- EXEC DELETE_ALL_CUSTOMERS
-- SELECT *
-- FROM CUSTOMER
-- ---------------------------TASK3--------------------------------------------
GO
IF OBJECT_ID('ADD_PRODUCT') IS NOT NULL
DROP PROCEDURE  ADD_PRODUCT;
GO
CREATE PROCEDURE ADD_PRODUCT @pprodid INT,@pprodname nvarchar(100),@pprice Money AS
BEGIN
     BEGIN TRY
        IF @pprodid<1000 OR @pprodid>2500
            THROW 50040,'Product ID out of range',1
        ELSE IF @pprice<0 OR @pprice>999.99
            THROW 50050,'Price out of range',1
        SELECT @pprodid=PRODID
        FROM PRODUCT
        IF @@ROWCOUNT!=0
            THROW 50030,'Duplicate product ID',1
        INSERT INTO Product(PRODID,PRODNAME, SELLING_PRICE,SALES_YTD) VALUES
        (@pprodid,@pprodname,@pprice,0)

     END TRY
     BEGIN CATCH
        IF ERROR_NUMBER() IN (50040,50050,50030)
            THROW
        ELSE
            BEGIN
              DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
              THROW 50000,@ERRORMESSAGE,1
            END;
     END CATCH;

END
-- GO

-- EXEC ADD_PRODUCT @pprodid=1111,@pprodname='WATER',@pprice=6;
-- GO
-- SELECT *
-- FROM Product

---------------------------------------task4-------------------------
GO
IF OBJECT_ID('DELETE_ALL_PRODUCTS') IS NOT NULL
DROP PROCEDURE  DELETE_ALL_PRODUCTS;
GO
CREATE PROCEDURE DELETE_ALL_PRODUCTS AS
BEGIN
    BEGIN TRY
        DELETE
        FROM PRODUCT
        PRINT (CONCAT('There are',@@ROWCOUNT,'rows affected'))

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()=50000
            BEGIN
              DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
              THROW 50000,@ERRORMESSAGE,1
            END;
    END CATCH;
END
-- GO
-- EXEC DELETE_ALL_PRODUCTS
-- SELECT *
-- FROM Product
-- ---------------------------------TASK5---------------------------------
GO
IF OBJECT_ID('GET_CUSTOMER_STRING') IS NOT NULL
DROP PROCEDURE   GET_CUSTOMER_STRING;
GO
CREATE PROCEDURE GET_CUSTOMER_STRING @pcustid int,@pReturnString NVARCHAR(1000) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @NAME NVARCHAR(100)
        DECLARE @STATUS NVARCHAR(7)
        DECLARE @SALES_YTD Money
            SELECT @NAME=CUSTNAME,@STATUS=STATUS,@SALES_YTD=SALES_YTD
            FROM CUSTOMER
            IF @@ROWCOUNT=0
                THROW 50060,'Customer ID not found',1
            SET @pReturnString=CONCAT('Custid:',@pcustid,'Name:',@NAME,'Status:',@STATUS,'SalesYTD:',@SALES_YTD)            
    END TRY

    BEGIN CATCH  
        IF ERROR_NUMBER()=50060
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
     END CATCH;
END
-- GO
-- BEGIN
-- DECLARE @OUTPUTVALUE NVARCHAR(1000)
-- EXEC GET_CUSTOMER_STRING @pcustid=123,@pReturnString=@OUTPUTVALUE OUTPUT;
-- PRINT (@OUTPUTVALUE)
-- END

-- ---------------------------------TASK6---------------------------------------------------------------
GO
IF OBJECT_ID('UPD_CUST_SALESYTD') IS NOT NULL
DROP PROCEDURE   UPD_CUST_SALESYTD;
GO
CREATE PROCEDURE UPD_CUST_SALESYTD @pcustid int,@pamt money AS
BEGIN
    BEGIN TRY 
    DECLARE @SALES_YTD_C_OLD MONEY
        IF @pamt<-999.99 or @pamt>999.99
             THROW 50110,'Amount out of range',1
             SELECT @SALES_YTD_C_OLD=SALES_YTD FROM CUSTOMER
        UPDATE CUSTOMER SET SALES_YTD=@pamt+@SALES_YTD_C_OLD
        WHERE CUSTID=@pcustid
        IF @@ROWCOUNT=0
            THROW 50100,'Customer ID not found',1
    END TRY
    BEGIN CATCH     
        IF ERROR_NUMBER() IN (50110,50100)
            THROW
        ELSE
            BEGIN  
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH

END
-- GO
-- EXEC UPD_CUST_SALESYTD @pcustid=123,@pamt=100
-- SELECT *
-- FROM CUSTOMER

-- -------------------------------------------TASK7-------------------------------------

GO
IF OBJECT_ID('GET_PROD_STRING') IS NOT NULL
DROP PROCEDURE   GET_PROD_STRING;
GO
CREATE PROCEDURE GET_PROD_STRING @pprodid int, @pReturnString NVARCHAR(1000) OUTPUT AS
BEGIN
    BEGIN TRY
        DECLARE @NAME NVARCHAR(100)
        DECLARE @PRICE MONEY
        DECLARE @SALES_YTD MONEY
          
            SELECT @NAME=PRODNAME,@PRICE=SELLING_PRICE,@SALES_YTD=SALES_YTD
            FROM PRODUCT
            IF @@ROWCOUNT=0
                 THROW 50060,'Product ID not found',1
                    
            SET @pReturnString=CONCAT('Prodid:',@pprodid,'Name:',@NAME,'Price:',@PRICE,'SalesYTD:',@SALES_YTD)           
    END TRY

    BEGIN CATCH  
        IF ERROR_NUMBER() IN (50060)
            THROW
        ELSE    
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
             END
    END CATCH;
END
-- GO
-- BEGIN
-- DECLARE @OUTPUTVALUE NVARCHAR(1000)
-- EXEC GET_PROD_STRING @pprodid=1111,@pReturnString=@OUTPUTVALUE OUTPUT;
-- PRINT (@OUTPUTVALUE)
-- END

-- ---------------------------------------------TASK8------------------------------------------------------
GO
IF OBJECT_ID('UPD_PROD_SALESYTD') IS NOT NULL
DROP PROCEDURE   UPD_PROD_SALESYTD;
GO
CREATE PROCEDURE UPD_PROD_SALESYTD @pprodid int,@pamt money AS
BEGIN
    BEGIN TRY
       
        DECLARE @SALES_YTD_OLD MONEY
        IF @pamt<-999.99 or @pamt>999.99
            THROW 50110,'Amount out of range',1
        SELECT @SALES_YTD_OLD=SALES_YTD FROM PRODUCT
        UPDATE PRODUCT SET SALES_YTD=@SALES_YTD_OLD+@pamt
            WHERE @pprodid=PRODID
        IF @@ROWCOUNT=0
                THROW 50100,'Product ID not found',1
    END TRY
    BEGIN CATCH
     IF ERROR_NUMBER() IN (50110,50100)
            THROW
       
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1

    END CATCH

END
-- GO
-- EXEC UPD_PROD_SALESYTD @pprodid=1111,@pamt=200
-- SELECT *
-- FROM PRODUCT
-- ---------------------------------------TASK9------------------------------------------------
GO
IF OBJECT_ID('UPD_CUSTOMER_STATUS') IS NOT NULL
DROP PROCEDURE   UPD_CUSTOMER_STATUS;
GO
CREATE PROCEDURE UPD_CUSTOMER_STATUS @pcustid int,@pstatus NVARCHAR(7) AS
BEGIN
    BEGIN TRY
    PRINT @pstatus
       IF @pstatus<>'OK' AND @pstatus<>'SUSPEND'
            THROW 50130,'Invalid Status value',1
        UPDATE CUSTOMER SET STATUS=@pstatus
        WHERE CUSTID=@pcustid
            
            IF @@ROWCOUNT=0
                THROW 50120,'Customer ID not found',1
        
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50130,50120)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH
END
-- GO
-- EXEC UPD_CUSTOMER_STATUS @pcustid=123,@pstatus='SUSPEND'
-- SELECT *
-- FROM CUSTOMER
-- -----------------------------TASK 10---------------------------
GO
IF OBJECT_ID('ADD_SIMPLE_SALE') IS NOT NULL
DROP PROCEDURE  ADD_SIMPLE_SALE;
GO

CREATE PROCEDURE ADD_SIMPLE_SALE @pcustid int,@pprodid int,@pqty int AS
BEGIN


    BEGIN TRY
        DECLARE @price MONEY
        DECLARE @P_NEWSALE_YTD MONEY
        DECLARE @C_NEWSALE_YTD MONEY
        DECLARE @STATUS NVARCHAR(7)

        SELECT @price=SELLING_PRICE
        FROM PRODUCT WHERE PRODID=@pprodid 
        IF @@ROWCOUNT=0
            THROW 50170,'Product ID not found',1
        IF @pqty<1 OR @pqty>999
            THROW 50140,'Sale Quantity outside valid range',1
        SET @P_NEWSALE_YTD=@pqty*@price

        SELECT @STATUS=STATUS
        FROM CUSTOMER WHERE CUSTID=@pcustid 
        IF @@ROWCOUNT=0
            THROW 50160,'Customer ID not found',1
        IF @STATUS<>'OK'
            THROW 50150, 'Customer status is not OK',1
        SET @C_NEWSALE_YTD=@pqty*@price

        EXEC UPD_CUST_SALESYTD @pcustid=@pcustid,@pamt=@C_NEWSALE_YTD
        EXEC UPD_PROD_SALESYTD @pprodid=@pprodid,@pamt=@P_NEWSALE_YTD
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50140,50150,50160,50170)
            THROW
        ELSE
            BEGIN
                 DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH
END
-- GO
-- EXEC ADD_SIMPLE_SALE @pcustid=123,@pprodid=1111,@pqty=6
-- SELECT * FROM CUSTOMER
-- SELECT *FROM PRODUCT
---------------------------TASK11-----------------------------------------------
GO
IF OBJECT_ID('SUM_CUSTOMER_SALESYTD') IS NOT NULL
DROP PROCEDURE  SUM_CUSTOMER_SALESYTD;
GO
CREATE PROCEDURE SUM_CUSTOMER_SALESYTD AS
BEGIN
    BEGIN TRY
        DECLARE @SUM MONEY
        SELECT @SUM=SUM(SALES_YTD)
        FROM CUSTOMER
        PRINT @SUM
        RETURN @SUM
    END TRY     
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1
         END
    END CATCH

END
-- GO
-- EXEC SUM_CUSTOMER_SALESYTD
-----------------------------------TASK12---------------------------------------------

GO

IF OBJECT_ID('SUM_PRODUCT_SALESYTD') IS NOT NULL
DROP PROCEDURE  SUM_PRODUCT_SALESYTD;
GO
CREATE PROCEDURE SUM_PRODUCT_SALESYTD AS
BEGIN
    BEGIN TRY
        DECLARE @SUM MONEY
        SELECT @SUM=SUM(SALES_YTD)
        FROM PRODUCT
        PRINT @SUM
        RETURN @SUM
    END TRY     
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1
         END
    END CATCH

END
-- GO
-- EXEC SUM_PRODUCT_SALESYTD
-----------------------------------------TASK13------------------------------------------------
-- GO
-- DELETE FROM CUSTOMER
-- INSERT INTO CUSTOMER(CUSTID,CUSTNAME,SALES_YTD,STATUS)VALUES
-- (123,'SARAH',0,'OK'),
-- (124,'KYLE',20,'OK'),
-- (125,'MAGGIE',10,'SUSPEND')
-- SELECT * FROM CUSTOMER
GO
IF OBJECT_ID('GET_ALL_CUSTOMERS') IS NOT NULL
DROP PROCEDURE GET_ALL_CUSTOMERS;
GO
CREATE PROCEDURE GET_ALL_CUSTOMERS @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
       SET @POUTCUR =CURSOR FOR SELECT * FROM CUSTOMER
       OPEN @POUTCUR
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1
        END
    END CATCH
END
GO
BEGIN
    DECLARE @custid int,@custname NVARCHAR(100),@SALES_YTD money,
        @STATUS NVARCHAR(7)

    DECLARE @MYCURSOR CURSOR
    EXEC GET_ALL_CUSTOMERS @POUTCUR=@MYCURSOR OUTPUT
    FETCH NEXT FROM @MYCURSOR INTO
        @custid,@custname,@SALES_YTD,@STATUS   
    WHILE @@FETCH_STATUS = 0  
        BEGIN  
            PRINT (CONCAT(@custid,' ',@custname,' ',@SALES_YTD,'  ',@STATUS))
               
            FETCH NEXT FROM @MYCURSOR INTO
                @custid,@custname,@SALES_YTD,@STATUS
        END  
    CLOSE @MYCURSOR
    DEALLOCATE @MYCURSOR
END

-------------------------------------------TASK14-----------------------------------
-- GO
-- EXEC  DELETE_ALL_PRODUCTS
-- GO
-- INSERT INTO PRODUCT(PRODID,PRODNAME,SELLING_PRICE,SALES_YTD)VALUES
-- (1111,'WATER',2,20),
-- (1112,'FLOUR',3,10),
-- (1113,'OIL',4,15)
-- SELECT * FROM PRODUCT
GO
CREATE PROCEDURE GET_ALL_PRODUCTS  @POUTCUR CURSOR VARYING OUTPUT AS 
BEGIN
    BEGIN TRY
      SET @POUTCUR =CURSOR FOR SELECT * FROM PRODUCT
       OPEN @POUTCUR 
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1
        END
    END CATCH
END
GO
BEGIN
 DECLARE @prodid int,@prodname NVARCHAR(100),@price MONEY,@SALES MONEY
        DECLARE @MYCURSOR CURSOR
        EXEC GET_ALL_PRODUCTS @POUTCUR=@MYCURSOR OUTPUT
        FETCH NEXT FROM @MYCURSOR INTO
        @prodid,@prodname,@price,@SALES
   
        WHILE @@FETCH_STATUS = 0  
            BEGIN  
                PRINT (CONCAT(@prodid,' ',@prodname,' ',@price,'  ',@SALES))
                FETCH NEXT FROM @MYCURSOR INTO
                @prodid,@prodname,@price,@SALES
            END  
            CLOSE @MYCURSOR
            DEALLOCATE @MYCURSOR
END

------------------------------------TASK15--------------------------------------------------

GO
IF OBJECT_ID('ADD_LOCATION') IS NOT NULL
DROP PROCEDURE ADD_LOCATION;
GO
CREATE PROCEDURE ADD_LOCATION @ploccode nvarchar(MAX),@pminqty int,@pmaxqty int AS
BEGIN
    BEGIN TRY
        IF LEN(@ploccode)!=5
            THROW 50190,'Location Code length invalid',1
        IF @pminqty<0 
            THROW 50200,'Minimum Qty out of range',1
        IF @pmaxqty>999
            THROW 50210,'Maximum Qty out of range',1
        IF @pminqty>@pmaxqty
            THROW 50220,'Minimum Qty larger than Maximum Qty',1
        SELECT * FROM LOCATION WHERE @ploccode=LOCID
        IF @@ROWCOUNT!=0
            THROW 50180,'Duplicate location ID',1
        INSERT INTO LOCATION(LOCID,MINQTY,MAXQTY)VALUES
        (@ploccode,@pminqty,@pmaxqty)
    

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50180,50190,50200,50210,50220)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
             END

    END CATCH

END
-- 
-----------------------------------------------------TASK 16---------------------------------
GO
IF OBJECT_ID('ADD_COMPLEX_SALE') IS NOT NULL
DROP PROCEDURE ADD_COMPLEX_SALE;
GO
CREATE PROCEDURE ADD_COMPLEX_SALE @pcustid int,@pprodid int,@pqty int,@pdate Nvarchar(max) AS
BEGIN
    BEGIN TRY
        DECLARE @price MONEY
        DECLARE @P_NEWSALE_YTD MONEY
        DECLARE @C_NEWSALE_YTD MONEY
        DECLARE @STATUS NVARCHAR(7)
        DECLARE @SaleId BIGINT

        IF @pqty<1 OR @pqty>999
        THROW 50230,'Sale Quantity outside valid range',1
        SELECT @price=SELLING_PRICE
        FROM PRODUCT WHERE PRODID=@pprodid 
        IF @@ROWCOUNT=0
            THROW 50270,'Product ID not found',1
      
        SET @P_NEWSALE_YTD=@pqty*@price

        SELECT @STATUS=STATUS
        FROM CUSTOMER WHERE CUSTID=@pcustid 
        IF @@ROWCOUNT=0
            THROW 50260,'Customer ID not found',1
        IF @STATUS<>'OK'
            THROW 50240, 'Customer status is not OK',1
        IF ISDATE(@pdate)!=1 or LEN(@pdate)!=8
            THROW 50250,'Date not valid',1
             SET @C_NEWSALE_YTD=@pqty*@price
        SET @SaleId =NEXT VALUE FOR SALE_SEQ
        INSERT INTO SALE(SALEID,CUSTID,PRODID,QTY,PRICE,SALEDATE)VALUES
        (@SaleId,@pcustid,@pprodid,@pqty,@price,@pdate)
        EXEC UPD_CUST_SALESYTD @pcustid=@pcustid,@pamt=@C_NEWSALE_YTD
        EXEC UPD_PROD_SALESYTD @pprodid=@pprodid,@pamt=@P_NEWSALE_YTD
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (50230,50240,50250,50260,50270)
            THROW
         ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
             END

    END CATCH
END
GO
-- EXEC ADD_COMPLEX_SALE @pcustid=123,@pprodid=1111,@pqty=10,@pdate=20200828
-- select * from SALE
-- SELECT * FROM CUSTOMER
-- SELECT * FROM PRODUCT
-- --------------------------task 17--------------------------------------------------------
GO
IF OBJECT_ID('GET_ALLSALES') IS NOT NULL
DROP PROCEDURE GET_ALLSALES;
GO
CREATE PROCEDURE GET_ALLSALES @POUTCUR CURSOR VARYING OUTPUT AS
BEGIN
    BEGIN TRY
        SET @POUTCUR  =CURSOR FOR SELECT * FROM SALE
        OPEN @POUTCUR
    END TRY
    BEGIN CATCH
        BEGIN
            DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
            THROW 50000,@ERRORMESSAGE,1
        END
    END CATCH
END

GO
BEGIN
 DECLARE @saleid BIGINT,@custid int,@prodid int,@qty int,@price MONEY,@date Date
        DECLARE @MYCURSOR CURSOR
        EXEC GET_ALLSALES @POUTCUR=@MYCURSOR OUTPUT
        FETCH NEXT FROM @MYCURSOR INTO
        @saleid,@custid,@prodid,@qty,@price,@date
   
        WHILE @@FETCH_STATUS = 0  
            BEGIN  
                PRINT (CONCAT(@saleid,' ',@custid,' ',@prodid,' ',@qty,'  ',@price,' ',@date))
                FETCH NEXT FROM @MYCURSOR INTO
                @saleid,@custid,@prodid,@qty,@price,@date
            END  
            CLOSE @MYCURSOR
            DEALLOCATE @MYCURSOR
END
-- --------------------------------------task18--------------------------------------------
GO
IF OBJECT_ID('COUNT_PRODUCT_SALES') IS NOT NULL
DROP PROCEDURE COUNT_PRODUCT_SALES;
GO
CREATE PROCEDURE COUNT_PRODUCT_SALES @PDAYS INT AS
BEGIN
    BEGIN TRY
        DECLARE @NumOfSale INT;
        SELECT @NumOfSale= COUNT(*) from SALE where SALEDATE > dateadd(dd,-@PDAYS,cast(getdate() as date))
        RETURN @NumOfSale
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
        THROW 50000,@ERRORMESSAGE,1
    END CATCH
END
-- GO
-- EXEC COUNT_PRODUCT_SALES @PDAYS=100
-- --------------------------------TASK19------------------------------------------------------------------
GO
IF OBJECT_ID('DELETE_SALE') IS NOT NULL
DROP PROCEDURE DELETE_SALE;
GO
CREATE PROCEDURE DELETE_SALE AS
BEGIN
    BEGIN TRY
        DECLARE @MINID INT,@price MONEY,@custid int,@proid int,@quantity int,@amount MONEY
        SELECT @MINID=MIN(SALEID) FROM SALE
        SELECT @price=PRICE,@custid=CUSTID,@proid=PRODID,@quantity=QTY FROM SALE
        WHERE SALEID=@MINID
        IF @@ROWCOUNT=0
        THROW 50280,'No Sale Rows Found',1
        SET @amount=@price*@quantity
        DELETE FROM SALE WHERE SALEID=@MINID
        EXEC UPD_CUST_SALESYTD @pcustid=@custid,@pamt=@amount
        EXEC UPD_PROD_SALESYTD  @pprodid=@proid,@pamt=@amount
        RETURN @MINID

    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER()=50280
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH

END
-- GO
-- select * from SALE
-- SELECT * FROM CUSTOMER
-- SELECT * FROM PRODUCT
-- GO
-- EXEC DELETE_SALE
-- select * from SALE
-- SELECT * FROM CUSTOMER
-- SELECT * FROM PRODUCT
-- -----------------------------------------task20---------------------------------------------------------------
GO
IF OBJECT_ID('DELETE_ALL_SALE') IS NOT NULL
DROP PROCEDURE DELETE_ALL_SALE;
GO
CREATE PROCEDURE DELETE_ALL_SALE AS
BEGIN
    BEGIN TRY
        DELETE FROM SALE
        UPDATE CUSTOMER SET SALES_YTD=0
        UPDATE PRODUCT SET SALES_YTD=0
    END TRY
    BEGIN CATCH
        DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
        THROW 50000,@ERRORMESSAGE,1
    END CATCH

END
-- ----------------------------------------TASK21-----------------------------
GO
IF OBJECT_ID('DELETE_CUSTOMER') IS NOT NULL
DROP PROCEDURE DELETE_CUSTOMER;
GO
CREATE PROCEDURE DELETE_CUSTOMER @pCustid int AS
BEGIN
    BEGIN TRY
         SELECT * FROM SALE WHERE CUSTID=@pCustid
        IF @@ROWCOUNT!=0
            THROW 50300,'Customer cannot be deleted as sales exist',1
        DELETE FROM CUSTOMER WHERE CUSTID=@pCustid
        IF @@ROWCOUNT=0
            THROW 50290,'Customer ID not found',1
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (500290,500300)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH
END
-- GO
-- EXEC DELETE_CUSTOMER @pCustid=123

-- -------------------------------------TASK22--------------------------------
GO
IF OBJECT_ID('DELETE_PRODUCT') IS NOT NULL
DROP PROCEDURE DELETE_PRODUCT;
GO
CREATE PROCEDURE DELETE_PRODUCT @pProdid int AS
BEGIN
    BEGIN TRY
         SELECT * FROM SALE WHERE PRODID=@pProdid 
        IF @@ROWCOUNT!=0
            THROW 50320,'Product cannot be deleted as sales exist',1
        DELETE FROM PRODUCT WHERE PRODID=@pProdid
        IF @@ROWCOUNT=0
            THROW 50310,'Product ID not found',1
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (500310,500320)
            THROW
        ELSE
            BEGIN
                DECLARE @ERRORMESSAGE NVARCHAR(MAX)=ERROR_MESSAGE();
                THROW 50000,@ERRORMESSAGE,1
            END
    END CATCH
END

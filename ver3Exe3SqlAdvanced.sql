-- Create a new database called 'sql_advanced'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
  SELECT name
    FROM sys.databases
    WHERE name = N'sql_advanced'
)
CREATE DATABASE sql_advanced
GO






CREATE TABLE users (
  [email] varchar(320) NOT NULL,
  [name] varchar(80) NOT NULL,
  [lastName] varchar(80) NOT NULL,
  [birthday] datetime NOT NULL,
  PRIMARY KEY ([email])
  )


CREATE TABLE login (
  [email] varchar(320) NOT NULL,
  [password] char(60) NOT NULL,
  PRIMARY KEY ([email]),
  FOREIGN KEY ([email]) REFERENCES users ([email]) on DELETE CASCADE
)

CREATE TABLE loginQuestion(
qid INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
question varchar(250),


)


CREATE TABLE loginrest (
  qid INT NOT NULL ,
  answer varchar(250) not null,
  email varchar(320) NOT NULL  ,
 
  FOREIGN KEY ([email]) REFERENCES  users ([email]) on DELETE CASCADE,
  FOREIGN KEY ([qid]) REFERENCES  loginQuestion([qid]) on DELETE CASCADE,
  PRIMARY KEY(qid,email)
)

CREATE TABLE loginlog (
  [email] varchar(320) NOT NULL,
  [time] datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  [succseslogin] int NOT NULL DEFAULT 0,
  PRIMARY KEY ([email],"time"),
  FOREIGN KEY ([email]) REFERENCES users ([email]) on DELETE CASCADE
)




--Q1
IF OBJECT_ID('loginInterface', 'U') IS NOT NULL
DROP TABLE  loginInterface
GO
-- Create the table in the specified schema
CREATE TABLE  loginInterface
(
    loginInterfaceID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- primary key column
    email [varchar](320) NOT NULL,
    password [char](60) NOT NULL,
    timelogin DATETIME default CURRENT_TIMESTAMP,
    -- specify more columns here
);
GO


CREATE OR ALTER TRIGGER clearloginattemp   
ON loginlog 

AFTER  INSERT 
AS 
BEGIN
DECLARE @emailLogin [varchar](320)
SELECT @emailLogin = email from inserted
-- Update rows in table 'TableName'
UPDATE loginInterface
SET
    [password] = '*****'
    
    -- add more columns and values here
WHERE 	loginInterface.email=@emailLogin/* add search conditions here */


END;

--create login logger in which logging the login attemps
CREATE OR ALTER  TRIGGER interfaceLoginLog   
ON loginInterface

AFTER INSERT 
AS 
BEGIN
--Declaration
DECLARE @emailLogin [varchar](320)
SELECT @emailLogin = email from inserted
 DECLARE @timeLogin DATETIME
 SELECT @timeLogin = timelogin from inserted
 DECLARE @passwordLogin [char](60)
 SELECT @passwordLogin = password from inserted

 DECLARE @passwordByEmail [char](60)
SELECT @passwordByEmail = password from [login] where [login].email=@emailLogin
-- Insert rows into table 'TableName'
INSERT INTO loginlog 
( -- columns to insert data into
 [email], [time], [succseslogin],[Operation]
)
VALUES
( -- first row: values for the columns in the list above
 @emailLogin, @timeLogin, IIF(@passwordLogin=@passwordByEmail,1,0),'login'
)

END;





/**
--Q1 TEST
-- Insert rows into table 'TableName'

--1.creating users
DELETE from loginAttemps
DELETE from loginInterface
DELETE from loginlog
DELETE from login
DELETE from users

insert into users
( -- columns to insert data into
 [email], [name],[lastName],[birthday]
)
VALUES--datetime format YYYY-MM-DD HH:MI:SS
( -- first row: values for the columns in the list above
 'david', 'david','musaev','1993-06-23 00:00:00'
),
( -- second row: values for the columns in the list above
 'yael', 'yaek','koko','1982-07-21 00:00:00'
),
( -- second row: values for the columns in the list above
 'ivan', 'ivan','kovoch','1992-04-24 00:00:00'
)
GO 

--creating login carditanlce
INSERT INTO login
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- first row: values for the columns in the list above
 'david', '1234'
),
( -- second row: values for the columns in the list above
 'yael', '4321'
),
( -- second row: values for the columns in the list above
 'ivan', 'abcd'
)
-- add more rows here
GO


--insert Trig attemp
-- Insert rows into table 'TableName'
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- first row: values for the columns in the list above
  'yael', '4321'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'yael', 'abcd'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'david', 'abcd'
)
-- add more rows here
GO

**/



--Q2
-- Create a new table called '[sql_advanced].[dbo]' in schema 'loginAttemps'
-- Drop the table if it already exists
IF OBJECT_ID(' loginAttemps', 'U') IS NOT NULL
DROP TABLE  loginAttemps
GO
-- Create the table in the specified schema
CREATE TABLE  loginAttemps
(
    loginAttempsID INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- primary key column
    email [varchar](320) NOT NULL,
    loginStatus [int] NOT NULL,
    timelogin DATETIME default CURRENT_TIMESTAMP,
    -- specify more columns here
);
GO

--drop the trigger
DROP TRIGGER  [isValid]
GO
--triger that block to many login attemps
CREATE OR ALTER  TRIGGER isValid 
ON loginlog    
AFTER INSERT  
AS 
BEGIN
 DECLARE @emailLogin [varchar](320)
SELECT @emailLogin = email from inserted
 DECLARE @timeLogin DATETIME
 SELECT @timeLogin = time from inserted
 DECLARE @loginStatus int
 SELECT @loginStatus = succseslogin from inserted
 DECLARE @numLoginAttemps3min INT
 SELECT @numLoginAttemps3min =counter from (

SELECT lg.email ,COUNT(lg.email) as 'counter'
 from loginlog lg
  WHERE lg.succseslogin > -1 AND lg.email=@emailLogin AND lg.time >= DATEADD(MINUTE, -3, getdate()) 
  GROUP BY lg.email
 )GO
 DECLARE @attempsInBlockTimePassed INT
 SELECT @attempsInBlockTimePassed =counter from (
SELECT lg.email ,COUNT(lg.email) as 'counter' 
from loginAttemps lg WHERE lg.loginStatus > -1 
AND lg.email=@emailLogin 
AND lg.timelogin >= DATEADD(MINUTE, -20, getdate())
 GROUP BY lg.email 
 )GO
  DECLARE @isBlocked int
  SELECT @isBlocked = loginStatus from 
  ( SELECT  TOP 1 email,loginStatus,timelogin 
    FROM loginAttemps lg
     WHERE lg.email=@emailLogin 
     ORDER BY lg.timelogin DESC 
  )GO
  DECLARE @blockOver int
  SELECT @blockOver = counter from (
  SELECT lg.email ,COUNT(lg.email) as 'counter' 
  from loginAttemps lg WHERE lg.loginStatus > -1 
  AND lg.email=@emailLogin 
  AND lg.timelogin <= DATEADD(MINUTE, -20, getdate()) 
  GROUP BY lg.email 
  )GO 

-- Insert rows into table 'TableName'
INSERT INTO  [loginAttemps]
( -- columns to insert data into
 [email], [loginStatus]
)
VALUES
( -- first row: values for the columns in the list above
  @emailLogin,CASE 
  WHEN @numLoginAttemps3min<4 AND @isBlocked=0 OR @isBlocked=1 OR @isBlocked IS NULL  THEN @loginStatus --just an attemp when user not blocked
  WHEN @numLoginAttemps3min>3 AND @isBlocked=0 OR @loginStatus=0  OR @isBlocked IS NULL   THEN 3 --block the user because he tried more then 3 times in last 3 minutes and he failed to enter right pass
  WHEN @isBlocked=3 AND @attempsInBlockTimePassed=0 AND @blockOver>0 THEN @loginStatus --release block
  WHEN @isBlocked=3 AND @attempsInBlockTimePassed>0 AND @blockOver>0 THEN 3 --renew block
  ELSE -1 --if smth else auto block
  END
)

END
--end of the trigger


/**
---Q2 TEST
--creating login carditanlce


DELETE from loginInterface
DELETE from loginlog
DELETE from loginAttemps
--insert Trig attemp
-- Insert rows into table 'TableName'
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- first row: values for the columns in the list above
  'yael', '4321'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'yael', 'abcd'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'david', 'abcd'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'david', '1234'
)
-- add more rows here
GO
**/





--Q3 login procedure
-- Create a new stored procedure called 'loginProcedure' in schema '[sql_advanced]'
-- Drop the stored procedure if it already exists
DROP PROCEDURE  [loginProcedure]
GO


-- Create the stored procedure in the specified schema
CREATE PROCEDURE loginProcedure
    @email /*parameter name*/ varchar(320) /*datatype_for_param1*/ = 'yael', /*default_value_for_param1*/
    @password /*parameter name*/ char(60) /*datatype_for_param1*/ = '1234' /*default_value_for_param2*/
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
   
    -- Insert rows into table 'TableName'
INSERT INTO  [loginInterface]
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  @email, @password
)
    GO
 
GO
--end of loginProcedure

/**
-- example to execute the stored procedure we just created
EXECUTE loginProcedure @email='yael' /*value_for_param1*/--,@password='abcd' /*value_for_param2*/
/**GO

/**EXECUTE loginProcedure @email='david' /*value_for_param1*/--,@password='abcd' /*value_for_param2*/
/**GO

EXECUTE loginProcedure @email='david' /*value_for_param1*/--,@password='1234' /*value_for_param2*/
/**GO**/





EXECUTE loginProcedure @email='david' /*value_for_param1*/,@password='1234'
--Q4 login  validation procedure
-- Create a new stored procedure called 'StoredProcedureName' in schema 'SchemaName'
-- Drop the stored procedure if it already exists
DROP PROCEDURE  [loginValidation]
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE  [loginValidation]
    @email /*parameter name*/ varchar(320) /*datatype_for_param1*/ = 'guest' /*default_value_for_param1*/
   
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
   
 SELECT counter from (
SELECT lg.email ,COUNT(lg.email) as 'counter' from loginAttemps lg WHERE lg.loginStatus = 1 AND lg.email=@email AND lg.timelogin >= DATEADD(SECOND, -30, getdate()) GROUP BY lg.email 
  )GO
GO
--end of login validation procedure

/*
-- example to execute the stored procedure we just created
EXECUTE  [loginValidation] "david" 
GO*/


--Q5 supporting in types of users
-- Create a new table called 'userType' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID(' [userType]', 'U') IS NOT NULL
DROP TABLE  [userType]
GO
-- Create the table in the specified schema
CREATE TABLE  [userType]
(
    userTypeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY, -- primary key column
    email [VARCHAR](320) NOT NULL,
    type [NVARCHAR](50) NOT NULL,
    FOREIGN KEY ([email]) REFERENCES users ([email]) on DELETE CASCADE
    -- specify more columns here
);
GO
--end of table creation


/**
--tests
DELETE from loginAttemps
DELETE from loginInterface
DELETE from loginlog
DELETE from login
DELETE from users

insert into users
( -- columns to insert data into
 [email], [name],[lastName],[birthday]
)
VALUES--datetime format YYYY-MM-DD HH:MI:SS
( -- first row: values for the columns in the list above
 'david', 'david','musaev','1993-06-23 00:00:00'
),
( -- second row: values for the columns in the list above
 'yael', 'yaek','koko','1982-07-21 00:00:00'
),
( -- second row: values for the columns in the list above
 'ivan', 'ivan','kovoch','1992-04-24 00:00:00'
)
GO 

--creating login carditanlce
INSERT INTO login
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- first row: values for the columns in the list above
 'david', '1234'
),
( -- second row: values for the columns in the list above
 'yael', '4321'
),
( -- second row: values for the columns in the list above
 'ivan', 'abcd'
)
-- add more rows here
GO


--insert Trig attemp
-- Insert rows into table 'TableName'
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- first row: values for the columns in the list above
  'yael', '4321'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'yael', 'abcd'
)
-- add more rows here
GO
INSERT INTO loginInterface
( -- columns to insert data into
 [email], [password]
)
VALUES
( -- second row: values for the columns in the list above
  'david', 'abcd'
)
-- add more rows here
GO

INSERT INTO userType
( -- columns to insert data into
 [email], [type]
)
VALUES
( -- second row: values for the columns in the list above
  'david', 3
)
-- add more rows here
GO
INSERT INTO userType
( -- columns to insert data into
 [email], [type]
)
VALUES
( -- second row: values for the columns in the list above
  'Ivan', 0
)
-- add more rows here
GO
INSERT INTO userType
( -- columns to insert data into
 [email], [type]
)
VALUES
( -- second row: values for the columns in the list above
  'Yael', 1
)
-- add more rows here
GO
**/


--Q6
--creating view of all blocked user in last 20 minutes
-- Drop the view if it already exists
DROP VIEW  [blockedUser]
GO
-- Create the view in the specified schema
CREATE VIEW  [blockedUser]
AS
    -- body of the view
    SELECT DISTINCT [email],
        [loginStatus]
        
    FROM  [loginAttemps] lg
    Where loginStatus =3 AND lg.timelogin >= DATEADD(MINUTE, -20, getdate())
GO
--end of view creation 



-- Create a new stored procedure called 'adminBlockReport' in schema '[dbo]'
-- Drop the stored procedure if it already exists

DROP PROCEDURE  [BlockReport]
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE  [BlockReport]
    @email /*parameter name*/ varchar(320) /*datatype_for_param1*/ = 'none'/*default_value_for_param1*/
   
-- add more stored procedure parameters here

AS
     DECLARE @userTypeLogin INT
     SELECT @userTypeLogin = type from (SELECT UT.type FROM userType  UT WHERE UT.email=@email)GO

    

IF @userTypeLogin=3--if admin show users that blocked
       SELECT * from blockedUser;


IF @userTypeLogin=1--if normal user show the login attemps history
   SELECT  [email],
        [loginStatus],[timelogin]
        
    FROM  [loginAttemps] lg
    Where email=@email

--end of BlockReport procedure


EXECUTE  [BlockReport] "yael" /*value_for_param1*/
GO



--how to check login
--1.login first
EXECUTE loginProcedure @email='david' /*value_for_param1*/,@password='1234'
-- example to execute the stored procedure we just created
--2.check the if counter==1 of the user
EXECUTE loginValidation "david" /*value_for_param1*/
GO


---add question

  INSERT INTO loginQuestion
( -- columns to insert data into
 [qid],[question]
)
VALUES
( -- first row: values for the columns in the list above
 '1','What is you mother name?'
),
( -- first row: values for the columns in the list above
 '2','What is you father name?'
),
( -- first row: values for the columns in the list above
 '3','What is you school name?'
),
( -- first row: values for the columns in the list above
'4','What is you birth city name?'
),
( -- first row: values for the columns in the list above
 '5','What is you Country birth name?'
)
-- add more rows here
GO

-- Create a new stored procedure called 'StoredProcedureName' in schema 'SchemaName'
-- Drop the stored procedure if it already exists

DROP PROCEDURE registerNewUser
GO
-- Create the stored procedure in the specified schema

CREATE PROCEDURE registerNewUser
  @email /*parameter name*/ varchar(320) /*datatype_for_param1*/ , /*default_value_for_param1*/
  @name /*parameter name*/ varchar(80) /*datatype_for_param1*/ , /*default_value_for_param1*/
  @lastName /*parameter name*/ varchar(320) /*datatype_for_param1*/ , /*default_value_for_param1*/
  @password /*parameter name*/ varchar(50) /*datatype_for_param1*/ , /*default_value_for_param2*/
  @birthday /*parameter name*/ datetime /*datatype_for_param1*/ , /*default_value_for_param2*/
   @q1 /*parameter name*/ varchar(250) /*datatype_for_param1*/ , /*default_value_for_param2*/
   @q2 /*parameter name*/ varchar(250)  /*datatype_for_param1*/, /*default_value_for_param2*/
   @q3 /*parameter name*/ varchar(250)  /*datatype_for_param1*/, /*default_value_for_param2*/
   @q4 /*parameter name*/ varchar(250)  /*datatype_for_param1*/ , /*default_value_for_param2*/
   @q5 /*parameter name*/ varchar(250)  /*datatype_for_param1*/  /*default_value_for_param2*/


-- add more stored procedure parameters here
AS
  -- body of the stored procedure
  begin Transaction
  -- Insert rows into table 'TableName'
  INSERT INTO users
  ( -- columns to insert data into
   [email], [name], [lastName],[birthday]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   @email, @name,@lastName,@birthday 
  );
  -- add more rows here
  save Transaction insertToUser
  INSERT INTO login
  ( -- columns to insert data into
   [email], [password]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   @email, @password
  );
  save Transaction insertToLogin
 INSERT INTO loginrest
  ( -- columns to insert data into
   [qid], [answer],[email]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   1,@q1,@email
  )
  save Transaction insertToLogin
  INSERT INTO loginrest
  ( -- columns to insert data into
   [qid], [answer],[email]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   2,@q2,@email
  )  save Transaction insertToLogin
  INSERT INTO loginrest
  ( -- columns to insert data into
   [qid], [answer],[email]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   3,@q3,@email
  )  save Transaction insertToLogin
  INSERT INTO loginrest
  ( -- columns to insert data into
   [qid], [answer],[email]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   4,@q4,@email
  )  save Transaction insertToLogin
  INSERT INTO loginrest
  ( -- columns to insert data into
   [qid], [answer],[email]
  )
  VALUES
  ( -- first row: values for the columns in the list above
   5,@q5,@email
  )  save Transaction insertToLogin


  rollback Transaction insertToLogin
 
  commit 
GO
;

EXECUTE registerNewUser @email="daddvasdadddMuseav@gmail.com" ,@password="1234",@name="david",@lastName="Musaev",
@birthday='1982-07-21 00:00:00',@q1='abra kabadra1',@q2='abra kabadra2',@q3='abra kabadra3',
@q4='abra kabadra4',@q5='abra kabadra5'
GO

--end procedure

-- example to execute the stored procedure we just created
EXECUTE registerNewUser @email="sivan" ,@password="1234",@
GO


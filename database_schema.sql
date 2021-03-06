-- Passwords 2.0
-- -------------
-- Host      : localhost\SQLEXPRESS
-- Database  : Passwords
-- Server   : Microsoft SQL Server


CREATE DATABASE Passwords
ON PRIMARY
  ( NAME = Passwords,
    SIZE = 8 MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 64 MB )
GO

USE Passwords
GO

--
-- Definition for table Users :
--

CREATE TABLE Users (
  Id int IDENTITY(1, 1) NOT NULL,
  Name varchar(15) NOT NULL,
  UserId varchar(15) NOT NULL,
  Password varchar(24) NOT NULL,
  PRIMARY KEY CLUSTERED (Id)
)
GO

--
-- Definition for table Categories :
--

CREATE TABLE Categories (
  CategoryId int IDENTITY(1, 1) NOT NULL,
  Category varchar(30) NOT NULL,
  Owner int NOT NULL,
  PRIMARY KEY CLUSTERED (CategoryId)
)
GO

--
-- Definition for table Passwords :
--

CREATE TABLE Passwords (
  Id int IDENTITY(1, 1) NOT NULL,
  [User] int NOT NULL,
  Description varchar(200) NOT NULL,
  LoginId varchar(200) NOT NULL,
  Password varchar(200) NOT NULL,
  WebSite varchar(400) NULL,
  Notes varchar(3000) NULL,
  CategoryId int NOT NULL,
  LastModified smalldatetime DEFAULT getdate() NOT NULL,
  PRIMARY KEY CLUSTERED (Id)
)
GO

--
-- Definition for stored procedure mysp_AddRecord :
--

CREATE PROCEDURE mysp_AddRecord
  @User int,
  @RecordId int,
  @Description varchar(200),
  @LoginId varchar(200),
  @Password varchar(200),
  @WebSite varchar(200),
  @Notes varchar(3000),
  @CategoryId int
AS
BEGIN

  IF @RecordId < 0
    BEGIN

      INSERT INTO [Passwords] ([User],[Description],[LoginId],[Password],[WebSite],[Notes],[CategoryId])
      VALUES (@User,@Description,@LoginId,@Password,@WebSite,@Notes,@CategoryId);

      SELECT @@IDENTITY

    END
  ELSE
    BEGIN

      UPDATE [Passwords] SET [Description]=@Description, [LoginId]=@LoginId,
        [Password]=@Password, [WebSite]=@WebSite, [Notes]=@Notes, [CategoryId]=@CategoryId
      WHERE [Id]=@RecordId;

      SELECT @RecordId

    END

END
GO

--
-- Definition for stored procedure mysp_AddUser :
--

CREATE PROCEDURE mysp_AddUser
  @Id int,
  @UserName varchar(15),
  @UserId varchar(15),
  @Password varchar(24)
AS
BEGIN

  IF @Id < 0
    BEGIN

      INSERT INTO [Users] ([Name],[UserId],[Password])
        VALUES (@UserName, @UserId, @Password);

      DECLARE @NewId int;
      SET @NewId = (SELECT [Id] FROM [Users] WHERE [UserId]=@UserId);

      INSERT INTO [Categories] ([Category], [Owner])
        VALUES ('General', @NewId);

      SELECT @NewId;

    END
  ELSE
    BEGIN

        UPDATE [Users] SET [Name]=@UserName, [UserId]=@UserId,
          [Password]=@Password WHERE [Id]=@Id;

        SELECT @Id;

    END

END
GO

--
-- Definition for indices :
--

ALTER TABLE Users
ADD UNIQUE NONCLUSTERED (UserId)
GO

--
-- Definition for foreign keys :
--

ALTER TABLE Categories
ADD CONSTRAINT [ Categories_fk] FOREIGN KEY (Owner)
  REFERENCES Users (Id)
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
GO

ALTER TABLE Passwords
ADD CONSTRAINT [ Passwords_fk] FOREIGN KEY ([User])
  REFERENCES Users (Id)
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
GO

ALTER TABLE Passwords
ADD CONSTRAINT [ Passwords_fk2] FOREIGN KEY (CategoryId)
  REFERENCES Categories (CategoryId)
  ON UPDATE NO ACTION
  ON DELETE NO ACTION
GO


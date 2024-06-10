-- Create Links Table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Links]') AND type in (N'U'))
BEGIN
    CREATE TABLE Links (
        id INT PRIMARY KEY IDENTITY,
        original_url NVARCHAR(2048),
        short_code NVARCHAR(10) UNIQUE,
        created_at DATETIME DEFAULT GETDATE(),
        expires_at DATETIME
    );
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Links]') AND type in (N'U'))
BEGIN
    -- Create LinkVisits Table
    CREATE TABLE LinkVisits (
        id INT PRIMARY KEY IDENTITY,
        short_code NVARCHAR(10),
        visited_at DATETIME DEFAULT GETDATE()
    );
END;


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Links]') AND type in (N'U'))
BEGIN
    CREATE TABLE Logs (
        Id INT PRIMARY KEY IDENTITY,
        Action_name NVARCHAR(50),
        table_name VARCHAR(30),
        row_name varchar(30),
        new_value varchar(30),
        user_name varchar(50),
        ActionTime DATETIME DEFAULT GETDATE(),
    );
END;

-- Create a stored procedure to get top 3 links by visits if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GetTop3Links]') AND type in (N'P'))
BEGIN
   CREATE trigger safeDB on databsae instead for drop_table , alter_table
        AS
        BEGIN
            SELECT TOP 3 short_code, COUNT(*) AS visits
            FROM LinkVisits
            GROUP BY short_code
            ORDER BY visits DESC;
        END
    -- EXEC('
    --     CREATE PROCEDURE GetTop3Links
    --     AS
    --     BEGIN
    --         SELECT TOP 3 short_code, COUNT(*) AS visits
    --         FROM LinkVisits
    --         GROUP BY short_code
    --         ORDER BY visits DESC;
    --     END
    -- ');
END;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Links]') AND type in (N'U'))
BEGIN
    CREATE TABLE Links (
        id INT PRIMARY KEY IDENTITY,
        original_url NVARCHAR(2048),
        short_code NVARCHAR(10) UNIQUE,
        created_at DATETIME DEFAULT GETDATE(),
        expires_at DATETIME
    );
END;

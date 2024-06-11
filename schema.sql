
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

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LinkVisits]') AND type in (N'U'))
BEGIN
    CREATE TABLE LinkVisits (
        id INT PRIMARY KEY IDENTITY,
        short_code NVARCHAR(10),
        visited_at DATETIME DEFAULT GETDATE()
    );
END;


IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Logs]') AND type in (N'U'))
BEGIN
    CREATE TABLE Logs (
        Id INT PRIMARY KEY IDENTITY,
        Action_name NVARCHAR(50),
        table_name VARCHAR(30),
        row_name varchar(30),
        user_name varchar(50),
        ActionTime DATETIME DEFAULT GETDATE(),
    );
END;

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE name = N'safeDB' AND parent_class_desc = 'DATABASE')
BEGIN
    EXEC('
        CREATE trigger safeDB ON DATABASE for DROP_TABLE, ALTER_TABLE
        AS
        BEGIN

            DECLARE @EventData XML;
            SET @EventData = EVENTDATA();

            DECLARE @Action_name NVARCHAR(50);
            DECLARE @row_name NVARCHAR(50) = NULL;


            SET @Action_name = @EventData.value(''(/EVENT_INSTANCE/EventType)[1]'', ''NVARCHAR(50)'');

            IF @Action_name = ''ALTER_TABLE''
            BEGIN
                DECLARE @AlterXML NVARCHAR(MAX) = @EventData.value(''(/EVENT_INSTANCE/TSQLCommand/CommandText)[1]'', ''NVARCHAR(MAX)'');

                -- Try to extract the column name from the TSQLCommand
                IF @AlterXML LIKE ''%DROP COLUMN%''
                BEGIN
                    SET @row_name = SUBSTRING(
                        @AlterXML, 
                        CHARINDEX(''DROP COLUMN'', @AlterXML) + LEN(''DROP COLUMN'') + 1, 
                        CHARINDEX('' '', @AlterXML + '' '', CHARINDEX(''DROP COLUMN'', @AlterXML) + LEN(''DROP COLUMN'') + 1) - (CHARINDEX(''DROP COLUMN'', @AlterXML) + LEN(''DROP COLUMN'') + 1)
                    );
                END
            END

            insert into link_shortener.dbo.Logs (Action_name,table_name,user_name,ActionTime,row_name)
            values (
                @EventData.value(''(/EVENT_INSTANCE/EventType)[1]'', ''NVARCHAR(50)''),
                @EventData.value(''(/EVENT_INSTANCE/ObjectName)[1]'', ''NVARCHAR(50)''),
                @EventData.value(''(/EVENT_INSTANCE/LoginName)[1]'', ''NVARCHAR(50)''),
                GETDATE(),
                @row_name
            );
            

            PRINT ''changes are not allowed on Tables.'';
        END
    ');
END;




IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[safe_logs_update]'))
BEGIN
    EXEC('
        CREATE trigger safe_logs_update on logs INSTEAD OF UPDATE
            AS
            BEGIN
                PRINT ''changes are not allowed on Log Table.'';
            END
    ');
END;

IF NOT EXISTS (SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID(N'[dbo].[safe_logs_delete]'))
BEGIN
    EXEC('
        CREATE trigger safe_logs_delete on logs INSTEAD OF DELETE
            AS
            BEGIN
                PRINT ''changes are not allowed on Log Table.'';
            END
    ');
END;

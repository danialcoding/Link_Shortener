-- Create Urls table
CREATE TABLE Urls (
    Id INT PRIMARY KEY IDENTITY,
    OriginalUrl NVARCHAR(2048) NOT NULL,
    ShortCode NVARCHAR(10) UNIQUE NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    LastAccessed DATETIME
);

-- Create Logs table
CREATE TABLE Logs (
    Id INT PRIMARY KEY IDENTITY,
    Action NVARCHAR(50),
    UrlId INT,
    ActionTime DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UrlId) REFERENCES Urls(Id)
);

-- Update last accessed date procedure
CREATE PROCEDURE UpdateLastAccessed
@ShortCode NVARCHAR(10)
AS
BEGIN
    UPDATE Urls
    SET LastAccessed = GETDATE()
    WHERE ShortCode = @ShortCode;
END;

-- Remove expired URLs procedure
CREATE PROCEDURE RemoveExpiredUrls
AS
BEGIN
    DELETE FROM Urls
    WHERE LastAccessed < DATEADD(week, -1, GETDATE())
    OR LastAccessed IS NULL AND CreatedAt < DATEADD(week, -1, GETDATE());
END;

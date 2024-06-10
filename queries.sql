
-- -- Create Logs table
-- CREATE TABLE Logs (
--     Id INT PRIMARY KEY IDENTITY,
--     Action NVARCHAR(50),
--     UrlId INT,
--     ActionTime DATETIME DEFAULT GETDATE(),
--     FOREIGN KEY (UrlId) REFERENCES Urls(Id)
-- );


-- newLinksInDay
SELECT count(*) as numbers_of_new_links
from Links
where DAY(created_at) == DAY(GETDATE());

-- visitsNumberInDay
SELECT id,original_url,short_code,count(*) as visits_number
from Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code & DAY(visited_at) == DAY(GETDATE())
ORDER BY visits_number;

-- topThreeLinksVisit
SELECT TOP 3 id,original_url,short_code,count(*) as visits_number
from Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code
ORDER BY visits_number;

-- getAllLinks
SELECT id,original_url,short_code,created_at,CONCAT(
        DATEDIFF(DAY, created_at, expires_at), ' Days, ',
        DATEDIFF(HOUR, created_at, expires_at) % 24, ' Hours, ',
        DATEDIFF(MINUTE, created_at, expires_at) % 60, ' Minutes, ',
        DATEDIFF(SECOND, created_at, expires_at) % 60, ' Seconds'
    ) AS RemainingTime,count(*) as visits_number
FROM Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code;


-- Update last accessed date procedure
-- CREATE PROCEDURE UpdateLastAccessed
-- @ShortCode NVARCHAR(10)
-- AS
-- BEGIN
--     UPDATE Urls
--     SET LastAccessed = GETDATE()
--     WHERE ShortCode = @ShortCode;
-- END;

-- -- Remove expired URLs procedure
-- CREATE PROCEDURE RemoveExpiredUrls
-- AS
-- BEGIN
--     DELETE FROM Urls
--     WHERE LastAccessed < DATEADD(week, -1, GETDATE())
--     OR LastAccessed IS NULL AND CreatedAt < DATEADD(week, -1, GETDATE());
-- END;



-- queries.sql


-- getLinkById
SELECT * FROM Links WHERE id = @id;

-- getLinkByShortCode
SELECT * FROM Links WHERE short_code = @shortCode;

-- insertLink
INSERT INTO Links (original_url, short_code, created_at) 
VALUES (@originalUrl, @shortCode, GETDATE());

-- updateLink
UPDATE Links SET original_url = @originalUrl WHERE id = @id;

-- deleteLink
DELETE FROM Links WHERE id = @id;

-- getLinkStats
SELECT COUNT(*) AS visits, short_code FROM LinkVisits GROUP BY short_code;

-- insertLinkVisit
INSERT INTO LinkVisits (short_code, visited_at) VALUES (@shortCode, GETDATE());



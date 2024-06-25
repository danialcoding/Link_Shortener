
-- getDailyNewLinks
SELECT count(*) as numbers_of_new_links
from Links
where DAY(created_at) = DAY(GETDATE());

-- getDailyLinkVisits
SELECT original_url,LinkVisits.short_code,count(*) as visits_number
from Links,LinkVisits
where Links.short_code = LinkVisits.short_code and DAY(visited_at) = DAY(GETDATE())
group by LinkVisits.short_code,original_url
ORDER BY visits_number desc;

-- getTop3Links
SELECT TOP 3 original_url,LinkVisits.short_code,ISNULL(COUNT(LinkVisits.short_code), 0) as visits_number
from Links LEFT JOIN LinkVisits ON Links.short_code = LinkVisits.short_code
group by LinkVisits.short_code,original_url
ORDER BY visits_number desc;

-- getAllLinksWithStats
SELECT 
    Links.original_url,
    Links.short_code,
    Links.created_at,
    CONCAT(
        DATEDIFF(DAY, Links.created_at, Links.expired_at), ' Days, ',
        DATEDIFF(HOUR, Links.created_at, Links.expired_at) % 24, ' Hours, ',
        DATEDIFF(MINUTE, Links.created_at, Links.expired_at) % 60, ' Minutes, ',
        DATEDIFF(SECOND, Links.created_at, Links.expired_at) % 60, ' Seconds'
    ) AS RemainingTime,
    ISNULL(COUNT(LinkVisits.short_code), 0) AS visits_number
FROM 
    Links
LEFT JOIN 
    LinkVisits ON Links.short_code = LinkVisits.short_code
GROUP BY 
    Links.original_url, 
    Links.short_code, 
    Links.created_at, 
    Links.expired_at;


-- checkexist
SELECT * FROM Links WHERE original_url = @originalUrl;

-- insertLink
INSERT INTO Links (original_url, short_code, created_at,expired_at) 
VALUES (@originalUrl, @shortCode, GETDATE(),DATEADD(WEEK, 1, GETDATE()));

-- getLinkByShortCode
SELECT * FROM Links WHERE short_code = @shortCode;

-- insertLinkVisit
INSERT INTO LinkVisits (short_code, visited_at) VALUES (@shortCode, GETDATE());

-- deleteExpiredLinks
DELETE FROM Links
WHERE expired_at < GETDATE();





-- -- getLinkById
-- SELECT * FROM Links WHERE id = @id;

-- -- updateLink
-- UPDATE Links SET original_url = @originalUrl WHERE id = @id;

-- -- deleteLink
-- DELETE FROM Links WHERE id = @id;

-- -- getLinkStats
-- SELECT COUNT(*) AS visits, short_code FROM LinkVisits GROUP BY short_code;




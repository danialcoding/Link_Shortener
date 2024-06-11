
-- getDailyNewLinks
SELECT count(*) as numbers_of_new_links
from Links
where DAY(created_at) == DAY(GETDATE());

-- getDailyLinkVisits
SELECT id,original_url,short_code,count(*) as visits_number
from Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code & DAY(visited_at) == DAY(GETDATE())
ORDER BY visits_number;

-- getTop3Links
SELECT TOP 3 id,original_url,short_code,count(*) as visits_number
from Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code
ORDER BY visits_number;

-- getAllLinksWithStats
SELECT id,original_url,short_code,created_at,CONCAT(
        DATEDIFF(DAY, created_at, expires_at), ' Days, ',
        DATEDIFF(HOUR, created_at, expires_at) % 24, ' Hours, ',
        DATEDIFF(MINUTE, created_at, expires_at) % 60, ' Minutes, ',
        DATEDIFF(SECOND, created_at, expires_at) % 60, ' Seconds'
    ) AS RemainingTime,count(*) as visits_number
FROM Links,LinkVisits
group by short_code
where Links.short_code = LinkVisits.short_code;



-- insertLink
INSERT INTO Links (original_url, short_code, created_at) 
VALUES (@originalUrl, @shortCode, GETDATE());

-- getLinkByShortCode
SELECT * FROM Links WHERE short_code = @shortCode;

-- insertLinkVisit
INSERT INTO LinkVisits (short_code, visited_at) VALUES (@shortCode, GETDATE());







-- -- getLinkById
-- SELECT * FROM Links WHERE id = @id;

-- -- updateLink
-- UPDATE Links SET original_url = @originalUrl WHERE id = @id;

-- -- deleteLink
-- DELETE FROM Links WHERE id = @id;

-- -- getLinkStats
-- SELECT COUNT(*) AS visits, short_code FROM LinkVisits GROUP BY short_code;




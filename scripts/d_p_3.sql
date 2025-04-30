UPDATE public.universal u
SET 
    avalaible = 'true',
    archived_date = NULL
FROM (
    SELECT u.internal_id
    FROM public.universal u
    INNER JOIN public."dnesnemovitosti___DATE_RAW__" i 
        ON u.site_id = i.id::text
    WHERE 
        u.source_id = '4'
        AND u.avalaible = 'false'
) AS returned
WHERE u.internal_id = returned.internal_id;
UPDATE public.universal u
SET 
    avalaible = 'false',
    archived_date = '__DATE__'
FROM (
    SELECT u.internal_id
    FROM public.universal u
    LEFT JOIN public.snemovitosti___DATE_RAW__ s 
        ON u.site_id = s.id::text
    WHERE 
        u.source_id = '1'
        AND u.avalaible = 'true'
        AND s.id IS NULL
) AS missing
WHERE u.internal_id = missing.internal_id;
UPDATE public.universal u
SET 
    avalaible = 'false',
    archived_date = '__DATE__'::date
FROM (
    SELECT u.internal_id
    FROM public.universal u
    LEFT JOIN public."dnesnemovitosti___DATE_RAW__" i 
        ON u.site_id = i.id::text
    WHERE 
        u.source_id = '4'
        AND u.avalaible = 'true'
        AND i.id IS NULL
) AS missing
WHERE u.internal_id = missing.internal_id;
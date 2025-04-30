UPDATE public.universal u
SET 
    avalaible = 'false',
    archived_date = '__DATE__'
FROM (
    SELECT u.internal_id
    FROM public.universal u
    LEFT JOIN public.beznemovitosti___DATE_RAW__ b 
        ON u.site_id = b.id::text
    WHERE 
        u.source_id = '2'
        AND b.id IS NULL
        AND u.added_date::date < '__DATE__'::date
) AS missing
WHERE u.internal_id = missing.internal_id;
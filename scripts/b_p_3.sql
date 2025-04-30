UPDATE public.universal u
SET 
    avalaible = 'true',
    archived_date = NULL
FROM public.beznemovitosti___DATE_RAW__ b
WHERE 
    u.avalaible = 'false'
    AND u.added_date < '__DATE__'
    AND u.source_id = '2'
    AND u.site_id = b.id::text
    AND LOWER(u.city) = LOWER(
        CASE 
            WHEN b.address ILIKE '%Praha%' THEN 'Praha'
            ELSE split_part(b.address, ',', 2)
        END
    )
    AND LOWER(u.street) = LOWER(trim(split_part(b.address, ',', 1)))
    AND u.deal_type = LOWER(split_part(b.offer_type, ' ', 1));
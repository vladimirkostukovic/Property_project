UPDATE public.universal u
SET
    avalaible = FALSE,
    archived_date = '__DATE__'
WHERE
    source_id = '3'
    AND avalaible = TRUE
    AND NOT EXISTS (
        SELECT 1
        FROM public."hypernemovitosti___DATE_RAW__" h
        WHERE h.listing_id = u.site_id
    );
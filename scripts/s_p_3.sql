UPDATE public.universal u
SET 
    avalaible = 'true',
    archived_date = NULL
FROM (
    SELECT
        s.id::text AS site_id,
        REGEXP_REPLACE(LOWER(TRIM(s.city)), '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g') AS city,
        REGEXP_REPLACE(LOWER(TRIM(s.street)), '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g') AS street,
        LOWER(TRIM(split_part(s.name, ' ', 1))) AS deal_type
    FROM public.snemovitosti___DATE_RAW__ s
) s_norm
WHERE 
    u.avalaible = 'false'
    AND u.added_date < '__DATE__'::date
    AND u.source_id = '1'
    AND u.site_id = s_norm.site_id
    AND LOWER(TRIM(u.city)) = s_norm.city
    AND LOWER(TRIM(u.street)) = s_norm.street
    AND u.deal_type = s_norm.deal_type;
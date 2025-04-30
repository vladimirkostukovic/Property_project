UPDATE public.universal u
SET 
    avalaible = 'true',
    archived_date = NULL
FROM public."hypernemovitosti___DATE_RAW__" h
WHERE 
    u.avalaible = 'false'
    AND u.added_date < '__DATE__'
    AND u.site_id = (h.data ->> 'ID inzerátu')::text
    AND LOWER(u.city) = LOWER(REGEXP_REPLACE(h.data ->> 'Lokalita', '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g'))
    AND LOWER(u.district) = LOWER(REGEXP_REPLACE(h.data ->> 'Kraj', '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g'))
    AND u.deal_type = LOWER(h.data ->> 'Typ nabídky')
    AND u.source_id = '3';
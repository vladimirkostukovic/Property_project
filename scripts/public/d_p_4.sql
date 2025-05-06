INSERT INTO public.universal_meta (internal_id, source_data)
SELECT 
    u.internal_id,
    i.data
FROM 
    public.universal u
INNER JOIN 
    public."dnesnemovitosti___DATE_RAW__" i
ON 
    u.site_id = i.id::text
    AND u.source_id = '4'
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM public.universal_meta um
        WHERE um.internal_id = u.internal_id
    );
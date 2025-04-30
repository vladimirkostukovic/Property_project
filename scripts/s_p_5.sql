INSERT INTO public.image_links (internal_id, source_data)
SELECT 
    u.internal_id,
    s.images::text
FROM public.snemovitosti___DATE_RAW__ s
JOIN public.universal u 
    ON u.site_id = s.id::text
WHERE u.source_id = '1'
  AND NOT EXISTS (
    SELECT 1 
    FROM public.image_links i
    WHERE i.internal_id = u.internal_id
);
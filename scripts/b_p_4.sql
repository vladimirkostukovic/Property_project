INSERT INTO public.image_links (internal_id, source_images)
SELECT 
    u.internal_id,
    b.images::text
FROM public.beznemovitosti___DATE_RAW__ b
JOIN public.universal u 
    ON u.site_id = b.id::text
WHERE u.source_id = '2'
  AND NOT EXISTS (
    SELECT 1 
    FROM public.image_links i
    WHERE i.internal_id = u.internal_id
);
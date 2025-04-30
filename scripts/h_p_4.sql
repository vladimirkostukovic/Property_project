INSERT INTO image_links (internal_id, source_images)
SELECT 
    u.internal_id,
    jsonb_path_query_array(h.data, '$.image_links')::text
FROM universal u
JOIN public."hypernemovitosti___DATE_RAW__" h 
    ON (h.data ->> 'ID inzerátu')::text = u.site_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM image_links i
    WHERE i.internal_id = u.internal_id
);
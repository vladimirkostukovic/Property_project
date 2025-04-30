INSERT INTO seller_info (
  internal_id,
  agent_name,
  agent_phone,
  agent_email,
  source_id
)
SELECT
  u.internal_id,
  h.data ->> 'Agent Name' AS agent_name,
  regexp_replace(
    COALESCE(NULLIF(h.data ->> 'Tel.', ''), NULLIF(h.data ->> 'Mobil', '')),
    '^\+?[0\s]*',
    '+420 '
  ) AS agent_phone,
  h.data ->> 'E-mail' AS agent_email,
  3 AS source_id
FROM public."hypernemovitosti___DATE_RAW__" AS h
JOIN public.universal AS u
  ON u.site_id = trim(h.data ->> 'ID inzerátu')
  AND u.source_id = 3
WHERE h.data ? 'Agent Name'
  AND NOT EXISTS (
    SELECT 1
    FROM seller_info si
    WHERE si.internal_id = u.internal_id
      AND si.source_id::INT = 3
  );
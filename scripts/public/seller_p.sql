INSERT INTO seller_info (internal_id, agent_name, agent_phone, agent_email, source_id)

SELECT 
    u.internal_id,
    s.agent_name,
    s.agent_phone,
    s.agent_email,
    u.source_id
FROM
    snemovitosti___DATE_RAW__ s
JOIN
    universal u ON CAST(u.site_id AS BIGINT) = s.id
WHERE
    u.source_id = '1'
    AND NOT EXISTS (
        SELECT 1
        FROM seller_info si
        WHERE si.internal_id = u.internal_id
          AND si.source_id::text = u.source_id::text
    )

UNION ALL

SELECT 
    u.internal_id,
    CASE 
        WHEN s.data->>'seller_info' IS NOT NULL AND s.data->>'seller_info' <> '' 
        THEN TRIM(split_part(s.data->>'seller_info', ',', 1)) 
        ELSE NULL 
    END,
    CASE 
        WHEN s.data->>'seller_info' IS NOT NULL AND s.data->>'seller_info' <> '' 
        THEN TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(s.data->>'seller_info', '.*?(\+420\s?\d{3}\s?\d{3}\s?\d{3}).*', '\1'),
                '\s+', '', 'g'
            )
        )
        ELSE NULL 
    END,
    CASE 
        WHEN s.data->>'seller_info' IS NOT NULL AND s.data->>'seller_info' <> '' 
        THEN LOWER(
            REGEXP_REPLACE(
                s.data->>'seller_info', 
                '.*?([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}).*', 
                '\1'
            )
        )
        ELSE NULL 
    END,
    '4'
FROM
    dnesnemovitosti___DATE_RAW__ s
JOIN
    universal u ON u.site_id = s.data->>'id'
WHERE
    u.source_id = '4'
    AND NOT EXISTS (
        SELECT 1
        FROM seller_info si
        WHERE si.internal_id = u.internal_id
          AND si.source_id::text = u.source_id::text
    )

UNION ALL

SELECT
    u.internal_id,
    h.data ->> 'Agent Name',
    regexp_replace(
        COALESCE(NULLIF(h.data ->> 'Tel.', ''), NULLIF(h.data ->> 'Mobil', '')),
        '^\+0\s*',
        '+420 '
    ),
    h.data ->> 'E-mail',
    3
FROM
    hypernemovitosti___DATE_RAW__ h
JOIN 
    universal u 
    ON u.site_id = trim(h.data ->> 'ID inzerátu') 
    AND u.source_id = 3
WHERE
    h.data ? 'Agent Name'
    AND NOT EXISTS (
        SELECT 1
        FROM seller_info si
        WHERE si.internal_id = u.internal_id
          AND si.source_id::integer = 3
    );
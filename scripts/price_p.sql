INSERT INTO price_change (internal_id, old_price, new_price, source_id)
SELECT
    res.internal_id,
    res.old_price,
    res.new_price,
    res.source_id
FROM (
    -- Source 1: snemovitosti
    SELECT
        u.internal_id,
        u.price::numeric AS old_price,
        ROUND(s.price_summary_czk::numeric, 0) AS new_price,
        u.source_id
    FROM public.universal u
    LEFT JOIN public."snemovitosti___DATE_RAW__" s 
        ON u.site_id = s.id::text
    WHERE 
        u.source_id = 1
        AND s.price_summary_czk IS NOT NULL
        AND u.price::numeric IS DISTINCT FROM ROUND(s.price_summary_czk::numeric, 0)

    UNION ALL

    -- Source 2: beznemovitosti
    SELECT
        u.internal_id,
        u.price::numeric AS old_price,
        b.price::numeric AS new_price,
        u.source_id
    FROM public.universal u
    LEFT JOIN public."beznemovitosti___DATE_RAW__" b 
        ON u.site_id = b.id::text
    WHERE 
        u.source_id = 2
        AND b.price IS NOT NULL
        AND u.price::numeric IS DISTINCT FROM b.price::numeric

    UNION ALL

    -- Source 3: hypernemovitosti
    SELECT
        u.internal_id,
        u.price::numeric AS old_price,
        REGEXP_REPLACE(h.data ->> 'Celkem', '[^0-9]', '', 'g')::numeric AS new_price,
        u.source_id
    FROM public.universal u
    LEFT JOIN public."hypernemovitosti___DATE_RAW__" h 
        ON u.site_id = h.id::text
    WHERE 
        u.source_id = 3
        AND (h.data ->> 'Celkem') IS NOT NULL
        AND REGEXP_REPLACE(h.data ->> 'Celkem', '[^0-9]', '', 'g') <> ''
        AND u.price::numeric IS DISTINCT FROM REGEXP_REPLACE(h.data ->> 'Celkem', '[^0-9]', '', 'g')::numeric

    UNION ALL

    -- Source 4: dnesnemovitosti
    SELECT
        u.internal_id,
        u.price::numeric AS old_price,
        COALESCE(
            NULLIF(h.data->>'Cena_numeric', '')::numeric,
            NULLIF(REGEXP_REPLACE(h.data->>'Cena', '[^0-9]', '', 'g'), '')::numeric
        ) AS new_price,
        u.source_id
    FROM public.universal u
    LEFT JOIN public."dnesnemovitosti___DATE_RAW__" h 
        ON u.site_id = h.id::text
    WHERE 
        u.source_id = 4
        AND (
            (h.data->>'Cena_numeric' IS NOT NULL AND h.data->>'Cena_numeric' <> '')
            OR (h.data->>'Cena' IS NOT NULL AND h.data->>'Cena' <> '')
        )
        AND u.price::numeric IS DISTINCT FROM COALESCE(
            NULLIF(h.data->>'Cena_numeric', '')::numeric,
            NULLIF(REGEXP_REPLACE(h.data->>'Cena', '[^0-9]', '', 'g'), '')::numeric
        )
) res
LEFT JOIN price_change pc 
    ON res.internal_id = pc.internal_id
WHERE 
    pc.internal_id IS NULL 
    OR pc.new_price IS DISTINCT FROM res.new_price;
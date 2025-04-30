INSERT INTO public.universal (
    site_id,
    added_date,
    avalaible,
    archived_date,
    source_id,
    category_value,
    category_name,
    name,
    deal_type,
    price,
    rooms,
    area_build,
    area_land,
    city_part,
    street,
    house_number,
    district_id,
    municipality_id,
    region_id,
    street_id,
    district,
    city,
    house_type
)
SELECT
    id::text AS site_id,
    '__DATE__'::date AS added_date,
    TRUE AS avalaible,
    NULL AS archived_date,
    4 AS source_id,

    CASE 
        WHEN type = 'apartments' THEN 1
        WHEN type = 'houses' THEN 2
        WHEN type = 'lands' THEN 3
        WHEN type = 'commercial' THEN 4
        WHEN type = 'garages' THEN 5
        ELSE NULL
    END AS category_value,

    CASE 
        WHEN type = 'apartments' THEN 'Byty'
        WHEN type = 'houses' THEN 'Domy'
        WHEN type = 'lands' THEN 'Pozemky'
        WHEN type = 'commercial' THEN 'Komerční'
        WHEN type = 'garages' THEN 'Ostatní'
        ELSE NULL
    END AS category_name,

    data->>'title' AS name,

    CASE 
        WHEN lower(data->>'title') LIKE '%pronájem%' THEN 'pronajem'
        WHEN lower(data->>'title') LIKE '%prodej%' THEN 'prodej'
        WHEN lower(data->>'title') LIKE '%dražba%' THEN 'drazba'
        ELSE NULL
    END AS deal_type,

    COALESCE(
        NULLIF(data->>'Cena_numeric', '')::numeric,
        NULLIF(REGEXP_REPLACE(data->>'Cena', '[^0-9]', '', 'g'), '')::numeric
    ) AS price,

    CASE 
        WHEN type IN ('apartments', 'houses') THEN (
            SELECT m[1]
            FROM regexp_matches(
              lower(data->>'title'), 
              '(garson(ka|iera)?|[1-9][0-9]*\+?[a-z]{1,3})', 
              'i'
            ) AS m
            LIMIT 1
        )
        ELSE NULL
    END AS rooms,

    CASE 
        WHEN type = 'apartments' THEN data->>'Užitná plocha'
        WHEN type = 'houses' THEN (
            SELECT match_arr[1]
            FROM regexp_matches(data->>'title', '([0-9]{2,4}) ?m²', 'g') AS match_arr
            LIMIT 1
        )
        ELSE NULL
    END AS area_build,

    CASE
        WHEN type = 'houses' THEN (
            SELECT match_arr[2]
            FROM regexp_matches(data->>'title', '([0-9]{2,4}) ?m²', 'g') AS match_arr
            WHERE array_length(match_arr, 1) >= 2
            LIMIT 1
        )
        ELSE data->>'Plocha pozemku'
    END AS area_land,

    CASE 
        WHEN data->>'address' ILIKE 'Praha % - %,%' THEN 
            trim(split_part(split_part(data->>'address', ',', 1), '-', 2))
        WHEN data->>'address' ILIKE 'okres %,%' THEN 
            trim(split_part(data->>'address', ',', 2))
        WHEN data->>'address' LIKE '%,%,%' THEN trim(split_part(data->>'address', ',', 2))
        WHEN data->>'address' LIKE '%,%' THEN trim(split_part(data->>'address', ',', 1))
        ELSE NULL
    END AS city_part,

    CASE 
        WHEN data->>'address' ILIKE 'Praha % - %,%' THEN 
            trim(split_part(data->>'address', ',', 2))
        WHEN data->>'address' ILIKE 'okres %,%' THEN NULL
        WHEN data->>'address' LIKE '%,%,%' THEN trim(split_part(data->>'address', ',', 1))
        ELSE NULL
    END AS street,

    NULL AS house_number,
    NULL AS district_id,
    NULL AS municipality_id,
    NULL AS region_id,
    NULL AS street_id,

    CASE 
        WHEN data->>'address' ILIKE 'Praha % - %,%' THEN 'Praha'
        WHEN data->>'address' ILIKE 'okres %,%' THEN split_part(data->>'address', ',', 1)
        WHEN data->>'address' LIKE '%,%,%' THEN trim(split_part(data->>'address', ',', 3))
        WHEN data->>'address' LIKE '%,%' THEN trim(split_part(data->>'address', ',', 2))
        ELSE data->>'address'
    END AS district,

    CASE 
        WHEN data->>'address' ILIKE 'Praha % - %,%' THEN 
            trim(split_part(split_part(data->>'address', ',', 1), '-', 2))
        WHEN data->>'address' ILIKE 'okres %,%' THEN 
            trim(split_part(data->>'address', ',', 2))
        WHEN data->>'address' LIKE '%,%,%' THEN trim(split_part(data->>'address', ',', 2))
        WHEN data->>'address' LIKE '%,%' THEN trim(split_part(data->>'address', ',', 1))
        ELSE NULL
    END AS city,

    data->>'Konstrukce budovy' AS house_type

FROM public."dnesnemovitosti___DATE_RAW__"
WHERE NOT EXISTS (
    SELECT 1
    FROM public.universal u
    WHERE u.site_id = id::text
    AND u.source_id = '4'
);
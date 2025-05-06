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
    (data ->> 'ID inzerátu')::text AS site_id,
    '__DATE__'::date AS added_date,
    TRUE AS avalaible,
    NULL AS archived_date,
    3 AS source_id,

    CASE
        WHEN data ->> 'Kategorie' ILIKE '%Byty%' THEN 1
        WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
        WHEN data ->> 'Kategorie' ILIKE '%pozemk%' THEN 3
        WHEN data ->> 'Kategorie' ILIKE '%komer%' THEN 4
        ELSE 5
    END AS category_value,

    data ->> 'Kategorie' AS category_name,
    data ->> 'Title' AS name,
    data ->> 'Typ nabídky' AS deal_type,
    REGEXP_REPLACE(data ->> 'Celkem', '[^0-9]', '', 'g')::bigint AS price,

    CASE
        WHEN (
            CASE
                WHEN data ->> 'Kategorie' ILIKE '%Byty%' THEN 1
                WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
                WHEN data ->> 'Kategorie' ILIKE '%pozemk%' THEN 3
                WHEN data ->> 'Kategorie' ILIKE '%komer%' THEN 4
                ELSE 5
            END
        ) = 1 THEN
            CASE
                WHEN data ->> 'Title' ILIKE ANY (ARRAY[
                    '%garsonk%', '%garzonk%', '%garsón%', '%garsoniér%'
                ]) THEN 'garsonka'
                ELSE SUBSTRING(data ->> 'Title' FROM '([0-9]+[+]?[0-9a-zA-Z]*)')
            END
        ELSE NULL
    END AS rooms,

    CASE
        WHEN (
            CASE
                WHEN data ->> 'Kategorie' ILIKE '%Byty%' THEN 1
                WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
                ELSE 0
            END
        ) > 0 AND data ? 'Užitná'
        THEN REGEXP_REPLACE(data ->> 'Užitná', '[^0-9]', '', 'g')::int
        WHEN (
            CASE
                WHEN data ->> 'Kategorie' ILIKE '%Byty%' THEN 1
                WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
                ELSE 0
            END
        ) > 0 AND data ? 'Plocha'
        THEN REGEXP_REPLACE(data ->> 'Plocha', '[^0-9]', '', 'g')::int
        ELSE (SELECT (REGEXP_MATCHES(data ->> 'Title', '([0-9]{2,4}) ?m2'))[1])::int
    END AS area_build,

    CASE
        WHEN (
            CASE
                WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
                WHEN data ->> 'Kategorie' ILIKE '%pozemk%' THEN 3
                ELSE 0
            END
        ) > 0 AND data ? 'Pozemku'
        THEN REGEXP_REPLACE(data ->> 'Pozemku', '[^0-9]', '', 'g')::int
        WHEN (
            CASE
                WHEN data ->> 'Kategorie' ILIKE '%domy%' THEN 2
                WHEN data ->> 'Kategorie' ILIKE '%pozemk%' THEN 3
                ELSE 0
            END
        ) > 0
        THEN (SELECT (REGEXP_MATCHES(data ->> 'Title', '([0-9]{2,4}) ?m2'))[1])::int
        ELSE NULL
    END AS area_land,

    NULL AS city_part,
    NULL AS street,
    NULL AS house_number,
    NULL AS district_id,
    NULL AS municipality_id,
    NULL AS region_id,
    NULL AS street_id,

    REGEXP_REPLACE(data ->> 'Kraj', '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g') AS district,
    REGEXP_REPLACE(data ->> 'Lokalita', '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g') AS city,

    CASE
        WHEN data ? 'typ'
        THEN REGEXP_REPLACE(data ->> 'typ', '[^[:alnum:]ěščřžýáíéúůĚŠČŘŽÝÁÍÉÚŮ ]', '', 'g')
        ELSE NULL
    END AS house_type

FROM public."hypernemovitosti___DATE_RAW__" h
WHERE NOT EXISTS (
    SELECT 1
    FROM public.universal u
    WHERE u.site_id = (data ->> 'ID inzerátu')::text
    AND u.source_id = '3'
);
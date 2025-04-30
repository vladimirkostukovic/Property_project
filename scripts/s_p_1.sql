INSERT INTO public.universal (
    site_id, added_date, avalaible, archived_date, source_id,
    category_value, category_name, name, deal_type, price, rooms,
    area_build, area_land, house_type, district, city, city_part,
    street, house_number, longitude, latitude,
    district_id, municipality_id, region_id, street_id
)
SELECT
    s.id::text AS site_id,
    '__DATE__' AS added_date,
    'true' AS avalaible,
    NULL AS archived_date,
    '1' AS source_id,
    s.category_value::text,
    s.category_name,
    s.name,
    LOWER(split_part(s.name, ' ', 1)) AS deal_type,
    ROUND(CAST(REPLACE(price_summary_czk, ' ', '') AS NUMERIC))::text AS price,
    r.rooms,
    CASE
        WHEN s.category_value IN ('1', '2', '4', '5') THEN r.area_build
        WHEN s.category_value = '3' THEN NULL
        ELSE NULL
    END AS area_build,
    CASE
        WHEN s.category_value = '3' THEN r.area_build
        WHEN s.category_value IN ('2', '4', '5') THEN r.area_land
        ELSE NULL
    END AS area_land,
    s.category_name AS house_type,
    s.district,
    s.city,
    s.city_part,
    s.street,
    CASE 
        WHEN house_number ~ '\d+' THEN REGEXP_REPLACE(house_number, '\D', '', 'g')
        ELSE NULL
    END AS house_number,
    s.longitude::text,
    s.latitude::text,
    s.district_id::text,
    s.municipality_id::text,
    s.region_id::text,
    s.street_id::text
FROM public.snemovitosti___DATE_RAW__ s
LEFT JOIN LATERAL (
    SELECT 
        (regexp_matches(s.name, '(\d+)[\s\u00A0]?m²(?:, pozemek (\d+)[\s\u00A0]?m²)?'))[1] AS area_build,
        (regexp_matches(s.name, '(\d+)[\s\u00A0]?m²(?:, pozemek (\d+)[\s\u00A0]?m²)?'))[2] AS area_land,
        (regexp_matches(s.name, '\d+\+(?:kk|\d+)', 'i'))[1] AS rooms
) r ON TRUE
WHERE NOT EXISTS (
    SELECT 1 FROM public.universal u
    WHERE u.site_id = s.id::text AND u.source_id = '1'
);
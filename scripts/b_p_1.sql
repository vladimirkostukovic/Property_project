INSERT INTO public.universal (
  site_id, added_date, avalaible, archived_date, source_id,
  category_value, category_name, name, deal_type, price,
  rooms, area_build, area_land, house_type,
  district, city, city_part, street,
  house_number, longitude, latitude,
  district_id, municipality_id, region_id, street_id
)
SELECT
  b.id::text                                    AS site_id,
  '__DATE__'::date                              AS added_date,
  TRUE                                          AS avalaible,
  NULL::date                                    AS archived_date,
  2                                             AS source_id,

  CASE LOWER(b.estate_type)
    WHEN 'pozemek'           THEN 3
    WHEN 'byt'               THEN 1
    WHEN 'dum'               THEN 2
    WHEN 'kancelar'          THEN 4
    WHEN 'nebytovy_prostor'  THEN 4
    WHEN 'garaz'             THEN 5
    ELSE NULL
  END                                            AS category_value,
  CASE LOWER(b.estate_type)
    WHEN 'pozemek'           THEN 'Pozemky'
    WHEN 'byt'               THEN 'Byty'
    WHEN 'dum'               THEN 'Domy'
    WHEN 'kancelar'          THEN 'Komerční'
    WHEN 'nebytovy_prostor'  THEN 'Komerční'
    WHEN 'garaz'             THEN 'Ostatní'
    ELSE 'Neznámá'
  END                                            AS category_name,

  b.image_alt_text                              AS name,
  LOWER(split_part(b.offer_type,' ',1))         AS deal_type,
  b.price::numeric                              AS price,

  COALESCE(
    lower(
      regexp_replace(
        regexp_replace(trim(b.disposition), '^DISP_', '', 'i'),
        '_','+','g'
      )
    ),
    substring(
      lower(b.image_alt_text)
      FROM '([1-6][+](?:kk|[1-6]))'
    )
  )                                             AS rooms,

  substring(
    b.image_alt_text
    FROM '([0-9]+(?:[.,][0-9]+)?)\s*(?:m2|m²|m\^2)'
  )::numeric                                     AS area_build,

  CASE
    WHEN lower(b.estate_type) = 'dum'
     AND b.image_alt_text ~* 'pozemek\s+([0-9]+(?:[.,][0-9]+)?)\s*(?:m2|m²|m\^2)'
    THEN substring(
           b.image_alt_text
           FROM 'pozemek\s+([0-9]+(?:[.,][0-9]+)?)\s*(?:m2|m²|m\^2)'
         )::numeric
    WHEN lower(b.estate_type) = 'pozemek'
    THEN substring(
           b.image_alt_text
           FROM '([0-9]+(?:[.,][0-9]+)?)\s*(?:m2|m²|m\^2)'
         )::numeric
    ELSE NULL
  END                                            AS area_land,

  b.estate_type                                  AS house_type,
  trim(
    COALESCE(NULLIF(split_part(b.address, ',',3), ''), split_part(b.address, ',',2))
  )                                              AS district,
  trim(
    CASE WHEN b.address ILIKE '%Praha%' THEN 'Praha'
         ELSE split_part(b.address, ',',2)
    END
  )                                              AS city,
  CASE
    WHEN split_part(b.address, ',',2) LIKE '%-%'
    THEN trim(split_part(split_part(b.address, ',',2),'-',2))
    ELSE NULL
  END                                            AS city_part,
  trim(split_part(b.address, ',',1))             AS street,

  NULL::text                                     AS house_number,
  NULL::numeric                                  AS longitude,
  NULL::numeric                                  AS latitude,
  NULL::integer                                  AS district_id,
  NULL::integer                                  AS municipality_id,
  NULL::integer                                  AS region_id,
  NULL::integer                                  AS street_id

FROM public.beznemovitosti___DATE_RAW__ b
WHERE NOT EXISTS (
    SELECT 1
    FROM public.universal ut
    WHERE ut.site_id = b.id::text
      AND ut.source_id = '2'
);
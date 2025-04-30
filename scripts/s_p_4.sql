INSERT INTO public.universal_meta (
    internal_id, price_czk,
    price_czk_per_sqm,
    status,
    data_hash,
    city_seo_name,
    region_seo_name,
    municipality_seo_name,
    geo_hash,
    inaccuracy_type,
    country,
    country_id,
    entity_type,
    ward,
    quarter,
    zip,
    raw_data,
    created_at,
    updated_at
)
SELECT
    u.internal_id, s.price_czk,
    s.price_czk_per_sqm,
    s.status,
    s.data_hash,
    s.city_seo_name,
    s.region_seo_name,
    s.municipality_seo_name,
    s.geo_hash,
    s.inaccuracy_type,
    s.country,
    s.country_id::text,
    s.entity_type,
    s.ward,
    s.quarter,
    s.zip,
    s.raw_data,
    s.created_at,
    s.updated_at
FROM public.snemovitosti___DATE_RAW__ s
JOIN public.universal u ON u.site_id = s.id::text
AND NOT EXISTS (
    SELECT 1 FROM public.universal_meta m
    WHERE m.internal_id = u.internal_id
);
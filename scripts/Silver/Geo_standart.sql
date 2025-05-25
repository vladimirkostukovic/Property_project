CREATE TABLE silver.ruian_ulice AS
SELECT
    -- География
    AVG("Souřadnice Y")::float4 AS center_y,
    AVG("Souřadnice X")::float4 AS center_x,

    -- Коды и названия
    MIN("Kód obce")::int4            AS kod_obce,
    MIN("Název obce")::varchar       AS nazev_obce,
    MIN("Kód obvodu Prahy")::varchar AS kod_obvodu_prahy,
    MIN("Název obvodu Prahy")::varchar AS nazev_obvodu_prahy,
    MIN("Kód části obce")::int4      AS kod_casti_obce,
    MIN("Název části obce")::varchar AS nazev_casti_obce,
    MIN("Kód ulice")::varchar        AS kod_ulice,
    COALESCE(NULLIF(MIN("Název ulice"), ''), MIN("Název části obce"))::varchar AS nazev_ulice,

    -- Добавляем: PSC
    MIN(psč)::int AS psc,

    -- Добавляем: регион (название края)
    MIN("Název obvodu Prahy")::varchar AS region -- Временно, потом подменим если нужно из kraje

FROM silver.of_adresses_raw

GROUP BY
    COALESCE(NULLIF("Kód ulice", ''), "Kód části obce"::varchar),
    COALESCE(NULLIF("Název ulice", ''), "Název části obce");
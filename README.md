# Realitní datová platforma

## Přehled

Projekt je navržen jako modulární ETL systém pro denní zpracování dat z realitního trhu. Využívá vícestupňovou architekturu (Bronze → Silver → Gold), výhradně postavenou na SQL. Vstupem jsou JSON data z externích skrapovacích nástrojů.

## Cíl

Vybudovat robustní a udržitelný nástroj, který:

- Každý den přijímá syrová data ve formátu JSON
- Segmentuje, čistí a normalizuje je pomocí SQL
- Uchovává historii změn
- Poskytuje strukturovaný výstup pro analýzy a automatizaci

## Technologie

- PostgreSQL (hlavní databáze)
- SQL (veškerá logika transformací)
- Apache Airflow (plánování a závislosti)
- Linux VPS (deployment)
- Git (verzování)
- Notion (dokumentace a plány)

## Architektura

```
[JSON vstupy ze skrapovacích nástrojů]
            ↓
         [Bronze]
Převod do unifikované tabulky `universal`, již očištěné a strukturované
            ↓
         [Silver]
Dodatečná typizace, segmentace dle kategorie a příprava na export
            ↓
         [Gold]
Agregace, historizace, výstupy pro reporting a API
```

## Tabulky

- `universal` – sjednocené realitní nabídky
- `universal_meta` – metadata a surové JSON vstupy
- `image_links` – odkazy na fotografie
- `seller_info` – informace o inzerentech
- `price_change` – sledování změn cen
- `removed_listings_*` – evidence neaktivních záznamů
- `silver.*` – typově rozdělené, očištěné datasety
- `gold.*` – analytické a exportní vrstvy (v přípravě)

## Automatizace

- `combined_daily_full_process` — plný denní tok: vkládání, archivace, reaktivace, metadata, obrázky
- `insert_price_change_and_seller_info` — změny cen a doplnění údajů o inzerentech

## Složková struktura

```
/scripts/
    ├── 1_insert_bronze.sql
    ├── 2_archive_missing.sql
    ├── 3_reactivate.sql
    ├── 4_to_meta.sql
    ├── 5_insert_images.sql
    ├── ...
/dags/
    ├── combined_daily_full_process.py
    ├── insert_price_change_and_seller_info.py
```

## Vlastnosti SQL zpracování

- Všechny transformace probíhají v SQL
- Vstupem je JSON z tabulek `*_RAW__`
- Již v Bronze vrstvě probíhá:
  - Parsování čísel, textu, lokalit, typů
  - Extrakce parametrů z názvů
  - Převod do unifikované tabulky
- Silver vrstva poté zajišťuje:
  - Dělení podle kategorií
  - Doplňování geodat a ID
  - Dedup podle hash nebo obrázků

## Roadmapa

- [x] Bronze vrstva a denní ingest JSON dat
- [x] Silver vrstva s typizací a kategorizací
- [x] Historie změn (price_change)
- [x] Metadata a odkazy na fotografie
- [x] Informace o inzerentech
- [ ] Porovnání obrázků pro deduplikaci
- [ ] GOLD vrstva s agregací a exporty
- [ ] První analytický reporting

---

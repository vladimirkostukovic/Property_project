# Real Estate Data Platform

## Overview

This project is a modular ETL system for daily processing of real estate market data in the Czech Republic. It is built on a layered SQL-only architecture (Bronze → Silver → Gold). The input consists of JSON data from various scraping tools.

## Objective

To create a robust and sustainable platform that:

- Ingests raw JSON data daily
- Segments, cleans, and normalizes via SQL
- Tracks historical changes
- Provides structured output for analysis and automation

## Technologies

- PostgreSQL (primary database)
- SQL (all transformation logic)
- Apache Airflow (scheduling and dependencies)
- Linux VPS (deployment)
- Git (version control)
- Notion (documentation and planning)

## Architecture

```
[JSON input from scrapers]
            ↓
         [Bronze]
Cleaned and structured into unified `universal` table
            ↓
         [Silver]
Typed and segmented by category, prepared for export
            ↓
         [Gold]
Aggregated and historized outputs for reporting and API
```

## Main Tables

- `universal` – unified real estate listings
- `universal_meta` – metadata and raw JSON payloads
- `image_links` – image URLs
- `seller_info` – seller and agent information
- `price_change` – price tracking over time
- `removed_listings_*` – archived inactive records
- `silver.*` – typed and cleaned datasets
- `gold.*` – analytical/export-ready datasets (in progress)

## Automation

- `combined_daily_full_process` – full daily DAG for ingestion, archiving, reactivation, metadata and image links
- `insert_price_change_and_seller_info` – tracks price changes and agent info

## Folder Structure

```
/scripts/
    ├── 1.sql
    ├── 2.sql
    ├── 3.sql
    ├── 4.sql
    ├── 5_.sql
    ├── ...
/dags/
    ├── combined_daily_full_process.py
    ├── insert_price_change_and_seller_info.py
```

## SQL Processing Highlights

- All transformation logic is in SQL
- Input from `*_RAW__` tables
- Bronze handles:
  - Parsing of numbers, text, location and type
  - Extracting fields from names
  - Structuring into the `universal` table
- Silver ensures:
  - Splitting by property type
  - Geo-matching and ID mapping
  - Deduplication by hash or image

## Roadmap

- Bronze layer with daily JSON ingestion
- Silver layer with typing and segmentation
- Price change tracking
- Metadata + photo links
- Agent/seller information
- Image deduplication
- Gold layer for aggregation and export
- First analytical reporting


---

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
    ├── 1.sql
    ├── 2.sql
    ├── 3.sql
    ├── 4.sql
    ├── 5.sql
    ├── ...
/dags/
    ├── combined_daily_full_process.py
    ├── insert_price_change_and_seller_info.py
```

## Vlastnosti SQL zpracování

- Všechny transformace probíhají v SQL
- Vstupem je JSON z tabulek *_RAW__
- Již v Bronze vrstvě probíhá:
  - Parsování čísel, textu, lokalit, typů
  - Extrakce parametrů z názvů
  - Převod do unifikované tabulky
- Silver vrstva poté zajišťuje:
  - Dělení podle kategorií
  - Doplňování geodat a ID
  - Dedup podle hash nebo obrázků

## Roadmapa

- Bronze vrstva a denní ingest JSON dat
- Silver vrstva s typizací a kategorizací
- Historie změn (price_change)
- Metadata a odkazy na fotografie
- Informace o inzerentech
- Porovnání obrázků pro deduplikaci
- GOLD vrstva s agregací a exporty
- První analytický reporting
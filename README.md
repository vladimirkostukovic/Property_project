{\rtf1\ansi\ansicpg1252\cocoartf2822
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 .AppleSystemUIFontMonospaced-Regular;}
{\colortbl;\red255\green255\blue255;\red181\green0\blue19;}
{\*\expandedcolortbl;;\cssrgb\c76863\c10196\c8627;}
\margl1440\margr1440\vieww26180\viewh15860\viewkind0
\pard\tx560\tx1120\tx1680\tx2240\tx2800\tx3360\tx3920\tx4480\tx5040\tx5600\tx6160\tx6720\pardirnatural\partightenfactor0

\f0\fs26 \cf2 # Realitn\'ed datov\'e1 platforma\
\
## P\uc0\u345 ehled\
\
Projekt je navr\'9een jako modul\'e1rn\'ed ETL syst\'e9m pro denn\'ed zpracov\'e1n\'ed dat z realitn\'edho trhu. Vyu\'9e\'edv\'e1 v\'edcestup\uc0\u328 ovou architekturu (Bronze \u8594  Silver \u8594  Gold), v\'fdhradn\u283  postavenou na SQL. Vstupem jsou JSON data z extern\'edch skrapovac\'edch n\'e1stroj\u367 .\
\
## C\'edl\
\
Vybudovat robustn\'ed a udr\'9eiteln\'fd n\'e1stroj, kter\'fd:\
\
- Ka\'9ed\'fd den p\uc0\u345 ij\'edm\'e1 syrov\'e1 data ve form\'e1tu JSON\
- Segmentuje, \uc0\u269 ist\'ed a normalizuje je pomoc\'ed SQL\
- Uchov\'e1v\'e1 historii zm\uc0\u283 n\
- Poskytuje strukturovan\'fd v\'fdstup pro anal\'fdzy a automatizaci\
\
## Technologie\
\
- PostgreSQL (hlavn\'ed datab\'e1ze)\
- SQL (ve\'9aker\'e1 logika transformac\'ed)\
- Apache Airflow (pl\'e1nov\'e1n\'ed a z\'e1vislosti)\
- Linux VPS (deployment)\
- Git (verzov\'e1n\'ed)\
- Notion (dokumentace a pl\'e1ny)\
\
## Architektura\
\
```\
[JSON vstupy ze skrapovac\'edch n\'e1stroj\uc0\u367 ]\
            \uc0\u8595 \
         [Bronze]\
P\uc0\u345 evod do unifikovan\'e9 tabulky `universal`, ji\'9e o\u269 i\'9at\u283 n\'e9 a strukturovan\'e9\
            \uc0\u8595 \
         [Silver]\
Dodate\uc0\u269 n\'e1 typizace, segmentace dle kategorie a p\u345 \'edprava na export\
            \uc0\u8595 \
         [Gold]\
Agregace, historizace, v\'fdstupy pro reporting a API\
```\
\
## Tabulky\
\
- `universal` \'96 sjednocen\'e9 realitn\'ed nab\'eddky\
- `universal_meta` \'96 metadata a surov\'e9 JSON vstupy\
- `image_links` \'96 odkazy na fotografie\
- `seller_info` \'96 informace o inzerentech\
- `price_change` \'96 sledov\'e1n\'ed zm\uc0\u283 n cen\
- `removed_listings_*` \'96 evidence neaktivn\'edch z\'e1znam\uc0\u367 \
- `silver.*` \'96 typov\uc0\u283  rozd\u283 len\'e9, o\u269 i\'9at\u283 n\'e9 datasety\
- `gold.*` \'96 analytick\'e9 a exportn\'ed vrstvy (v p\uc0\u345 \'edprav\u283 )\
\
## Automatizace\
\
- `combined_daily_full_process` \'97 pln\'fd denn\'ed tok: vkl\'e1d\'e1n\'ed, archivace, reaktivace, metadata, obr\'e1zky\
- `insert_price_change_and_seller_info` \'97 zm\uc0\u283 ny cen a dopln\u283 n\'ed \'fadaj\u367  o inzerentech\
\
## Slo\'9ekov\'e1 struktura\
\
```\
/scripts/\
    \uc0\u9500 \u9472 \u9472  1_insert_bronze.sql\
    \uc0\u9500 \u9472 \u9472  2_archive_missing.sql\
    \uc0\u9500 \u9472 \u9472  3_reactivate.sql\
    \uc0\u9500 \u9472 \u9472  4_to_meta.sql\
    \uc0\u9500 \u9472 \u9472  5_insert_images.sql\
    \uc0\u9500 \u9472 \u9472  ...\
/dags/\
    \uc0\u9500 \u9472 \u9472  combined_daily_full_process.py\
    \uc0\u9500 \u9472 \u9472  insert_price_change_and_seller_info.py\
```\
\
## Vlastnosti SQL zpracov\'e1n\'ed\
\
- V\'9aechny transformace prob\'edhaj\'ed v SQL\
- Vstupem je JSON z tabulek `*_RAW__`\
- Ji\'9e v Bronze vrstv\uc0\u283  prob\'edh\'e1:\
  - Parsov\'e1n\'ed \uc0\u269 \'edsel, textu, lokalit, typ\u367 \
  - Extrakce parametr\uc0\u367  z n\'e1zv\u367 \
  - P\uc0\u345 evod do unifikovan\'e9 tabulky\
- Silver vrstva pot\'e9 zaji\'9a\uc0\u357 uje:\
  - D\uc0\u283 len\'ed podle kategori\'ed\
  - Dopl\uc0\u328 ov\'e1n\'ed geodat a ID\
  - Dedup podle hash nebo obr\'e1zk\uc0\u367 \
\
## Roadmapa\
\
- [x] Bronze vrstva a denn\'ed ingest JSON dat\
- [x] Silver vrstva s typizac\'ed a kategorizac\'ed\
- [x] Historie zm\uc0\u283 n (price_change)\
- [x] Metadata a odkazy na fotografie\
- [x] Informace o inzerentech\
- [ ] Porovn\'e1n\'ed obr\'e1zk\uc0\u367  pro deduplikaci\
- [ ] GOLD vrstva s agregac\'ed a exporty\
- [ ] Prvn\'ed analytick\'fd reporting\
\
---\
}
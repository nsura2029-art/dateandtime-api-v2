# M5: Translations Audit Report

**Date:** 2026-08-01
**Source:** dr5hn translations.csv (2,965,564 valid rows)
**Migration:** 130 (schema) + 131 (30-part import)

## Counts

| Metric | Value |
|---|---:|
| Total translations | **2,965,561** |
| Expected | 2,965,564 |
| Match | ✅ 100% |
| Cities with full 19 langs | 149,764 |

## By Place Type

| Type | Distinct places | Total translations |
|---|---:|---:|
| city            | 150,465 |  2,859,098 |
| state           |  5,296 |    101,309 |
| country         |    250 |      4,723 |
| subregion       |     22 |        329 |
| region          |      6 |        102 |

## Languages (19 supported)

| Code | Cities | Translations |
|---|---:|---:|
| fr     | 150,447 |    150,447 |
| ar     | 150,445 |    150,445 |
| nl     | 150,444 |    150,444 |
| de     | 150,443 |    150,443 |
| pl     | 150,442 |    150,442 |
| it     | 150,441 |    150,441 |
| ru     | 150,441 |    150,441 |
| es     | 150,440 |    150,440 |
| tr     | 150,438 |    150,438 |
| ja     | 150,435 |    150,435 |
| ko     | 150,435 |    150,435 |
| pt     | 150,435 |    150,435 |
| uk     | 150,434 |    150,434 |
| hi     | 150,431 |    150,431 |
| fa     | 150,430 |    150,430 |
| zh-CN  | 150,430 |    150,430 |
| br     | 150,429 |    150,429 |
| hr     | 150,429 |    150,429 |
| pt-BR  | 150,429 |    150,429 |
| en     |     553 |        553 |
| zh     |     126 |        126 |
| id     |      67 |         67 |
| vi     |      40 |         40 |
| bn     |      11 |         11 |
| ga     |       1 |          1 |
| hy     |       1 |          1 |
| ur     |       1 |          1 |

## Indexes

- sqlite_autoindex_translations_1
- idx_translations_place
- idx_translations_lang
- idx_translations_city
- idx_translations_country
- idx_translations_state
- idx_translations_lang_search

## Sample Translations

### Tokyo (id 64500) - 19 langs

| Language | Translation |
|---|---|
| ar     | طوكيو |
| br     | Tokyo |
| de     | Tokio |
| es     | Tokio |
| fa     | توکیو |
| fr     | Tokyo |
| hi     | टोक्यो |
| hr     | Tokio |
| it     | Tokio |
| ja     | 東京 |
| ko     | 도쿄 |
| nl     | Tokio |
| pl     | Tokio |
| pt     | Tóquio |
| pt-BR  | Tóquio |
| ru     | Токио |
| tr     | Tokyo |
| uk     | Токіо |
| zh-CN  | 东京 |

### Beijing (id 19332) - 9 sample langs

| Language | Translation |
|---|---|
| ar     | بكين |
| de     | Peking |
| es     | Pekín |
| fr     | Pékin |
| ja     | 北京 |
| ko     | 베이징 |
| ru     | Пекин |
| zh-CN  | 北京 |

## API Endpoints

- GET /api/v1/cities/{id}/translations - All 19 langs for a city
- GET /api/v1/cities/{id}/translations/{lang} - Single lang (e.g. /ja, /zh-CN)
- GET /api/v1/translations/search?q=&lang= - Search cities by translated name

## Tests

tests/translations.test.ts: 11/11 pass
Test count: 131/132 pass (1 pre-existing unrelated env.test.ts)

Cumulative pass rate: 113/209 spec tests (54.1%)

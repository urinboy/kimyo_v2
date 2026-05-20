---
name: Project Overview
description: Kimyo v2 loyihasi haqida asosiy ma'lumotlar — maqsad, auditoriya va arxitektura.
---

# Kimyo V2 — Loyiha Bayoni

## Maqsad
9-sinf o'quvchilari uchun metallar va Qoraqalpog'iston tabiiy resurslarini o'rganishga mo'ljallangan kompleks ta'lim platformasi.

## Uch Qatlamli Arxitektura
| Qatlam | Texnologiya | Papka |
|--------|-------------|-------|
| Backend API | Laravel 13, PHP 8.3+ | `/api` |
| Admin Panel | React 19 + TypeScript + Vite | `/admin` |
| Mobil Ilova | Flutter (Clean Architecture) | `/mobile` |

## Dizayn Prinsipi — Premium Glassmorphism
| Token | Qiymat |
|-------|--------|
| Primary Purple | `#A855F7` / `hsl(270, 95%, 65%)` |
| Primary Green | `#10B981` / `hsl(160, 84%, 39%)` |
| Glass White | `rgba(255,255,255,0.1)` |
| Glass Border | `rgba(255,255,255,0.2)` |
| Backdrop Blur | 8px – 16px |

## Agentlar Tizimi
- **Miya** — Markaziy koordinator
- **Admin UI Guardian** — Vizual yaxlitlik
- **Laravel Backend** — API va DB
- **Flutter Architect** — Mobil
- **Swagger Architect** — API dokumentatsiya
- **UI Designer** — Dizayn eksperti

## Tillar
- O'zbek (asosiy), Rus, Ingliz
- Web: `i18next`, Mobil: `flutter_localizations` + `intl`

## Versiya
2.4.26 (Build 22)

---
name: Documentation & Archiving Standards
description: Artefakt fayllarni yaratish va arxivlash qoidalari.
---

# Hujjatlashtirish va Arxivlash Standartlari

## Fayl Joylashuvi
| Tur | Papka |
|-----|-------|
| Implementation plans | `.claude/artifacts/implementation_plan/` |
| Tasks | `.claude/artifacts/task/` |
| Walkthroughs | `.claude/artifacts/walkthrough/` |

## Fayl Nomlash Formati
```
yyyy-mm-dd-HH-MM-[vazifa-nomi].md
```
**Misol:** `2026-04-26-10-55-mobile-formula-calculator.md`

**MUHIM:** Hozirgi aniq vaqtni ishlat — kelgusi sana yoki noto'g'ri vaqt **qat'iyan man**.

## Ish Jarayoni
1. Har "Feature" yoki migration oldidan → `implementation_plan` fayl yaratish
2. Tasdiqlangandan so'ng → `task` fayl yaratish
3. Yakunlangandan so'ng → `walkthrough` fayl yaratish

## Task Fayl Tuzilishi
```markdown
# [Vazifa nomi]
**Status:** PENDING | IN_PROGRESS | COMPLETED
**Sana:** yyyy-mm-dd

## Todos
- [ ] ...

## Ta'sirlangan Fayllar
- ...
```

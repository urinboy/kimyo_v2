# Dissertatsiya Tadqiqot Natijalarini Dashboard da Ko'rsatish

**Status:** PENDING
**Sana:** 2026-05-15

---

## Maqsad

`demos/hisoblah.pdf` dagi dissertatsiya tadqiqot ma'lumotlarini (3 tuman bo'yicha tajriba-sinov natijalari) admin panel dashboardiga interaktiv vizualizatsiya sifatida qo'shish.

---

## PDF Tahlili — Asosiy Ma'lumotlar

### Ma'lumot Tuzilishi

| Tuman | Tajriba guruhi | Nazorat guruhi |
|-------|---------------|----------------|
| Shumanay | 190 o'quvchi | 196 o'quvchi |
| Qanliko'l | 148 o'quvchi | 145 o'quvchi |
| Ellikqal'a | 140 o'quvchi | 135 o'quvchi |
| **Jami** | **478** | **476** |

### Statistik Natijalar (Yakuniy)

| Tuman | chi2_boshi | chi2_oxiri | x_tajriba | y_nazorat | eta | Farq |
|-------|-----------|-----------|----------|----------|-----|------|
| Shumanay | 1.07 | 35.50 | 3.64 | 3.27 | 1.11 | +12% |
| Qanliko'l | 1.33 | 26.91 | 3.70 | 3.31 | 1.12 | +13% |
| Ellikqal'a | 3.20 | 23.24 | 3.72 | 3.36 | 1.11 | +13% |
| **Jami** | **4.17** | **85.38** | **3.68** | **3.31** | **1.11** | **+11%** |

Kritik qiymat: chi2_krit = **7.81** (alfa=0.05, df=3)

---

## Arxitektura

### Yondashuv: Static JSON → Laravel Method → React Component

Ma'lumotlar dissertatsiya natijalari (static). DB jadval shart emas.

---

## Bajarish Bosqichlari

### 1-qadam — Backend: `researchStats()` metod + Route

**Fayl:** `backend/app/Http/Controllers/Api/DashboardController.php`

`researchStats(): JsonResponse` metod qo'shish. Qaytaradi:
```json
{
  "status": "success",
  "data": {
    "districts": [
      {
        "id": "shumanay",
        "name": "Shumanay tumani",
        "tajriba_count": 190,
        "nazorat_count": 196,
        "grades": [
          {
            "label": "A'lo", "grade": 5,
            "tajriba_tb": 12, "tajriba_tb_pct": 6,
            "tajriba_to": 18, "tajriba_to_pct": 9,
            "nazorat_tb": 10, "nazorat_tb_pct": 5,
            "nazorat_to": 7,  "nazorat_to_pct": 4
          },
          {"label": "Yaxshi",     "grade": 4, "tajriba_tb": 65, "tajriba_tb_pct": 34, "tajriba_to": 85, "tajriba_to_pct": 45, "nazorat_tb": 73, "nazorat_tb_pct": 34, "nazorat_to": 66, "nazorat_to_pct": 34},
          {"label": "Qoniqarli",  "grade": 3, "tajriba_tb": 76, "tajriba_tb_pct": 40, "tajriba_to": 87, "tajriba_to_pct": 46, "nazorat_tb": 81, "nazorat_tb_pct": 41, "nazorat_to": 95, "nazorat_to_pct": 48},
          {"label": "Qoniqarsiz", "grade": 2, "tajriba_tb": 37, "tajriba_tb_pct": 20, "tajriba_to": 0,  "tajriba_to_pct": 0,  "nazorat_tb": 32, "nazorat_tb_pct": 20, "nazorat_to": 28, "nazorat_to_pct": 14}
        ],
        "stats": {"chi2_start": 1.07, "chi2_end": 35.50, "mean_tajriba": 3.64, "mean_nazorat": 3.27, "eta": 1.11, "improvement_pct": 12}
      },
      {
        "id": "qanliko_l",
        "name": "Qanliko'l tumani",
        "tajriba_count": 148, "nazorat_count": 145,
        "grades": [
          {"label": "A'lo",       "grade": 5, "tajriba_tb": 5,  "tajriba_tb_pct": 3,  "tajriba_to": 13, "tajriba_to_pct": 9,  "nazorat_tb": 3,  "nazorat_tb_pct": 2,  "nazorat_to": 5,  "nazorat_to_pct": 3},
          {"label": "Yaxshi",     "grade": 4, "tajriba_tb": 58, "tajriba_tb_pct": 39, "tajriba_to": 77, "tajriba_to_pct": 52, "nazorat_tb": 65, "nazorat_tb_pct": 45, "nazorat_to": 53, "nazorat_to_pct": 37},
          {"label": "Qoniqarli",  "grade": 3, "tajriba_tb": 59, "tajriba_tb_pct": 40, "tajriba_to": 58, "tajriba_to_pct": 39, "nazorat_tb": 52, "nazorat_tb_pct": 36, "nazorat_to": 69, "nazorat_to_pct": 48},
          {"label": "Qoniqarsiz", "grade": 2, "tajriba_tb": 26, "tajriba_tb_pct": 18, "tajriba_to": 0,  "tajriba_to_pct": 0,  "nazorat_tb": 25, "nazorat_tb_pct": 17, "nazorat_to": 18, "nazorat_to_pct": 12}
        ],
        "stats": {"chi2_start": 1.33, "chi2_end": 26.91, "mean_tajriba": 3.70, "mean_nazorat": 3.31, "eta": 1.12, "improvement_pct": 13}
      },
      {
        "id": "ellikqala",
        "name": "Ellikqal'a tumani",
        "tajriba_count": 140, "nazorat_count": 135,
        "grades": [
          {"label": "A'lo",       "grade": 5, "tajriba_tb": 8,  "tajriba_tb_pct": 6,  "tajriba_to": 13, "tajriba_to_pct": 9,  "nazorat_tb": 4,  "nazorat_tb_pct": 3,  "nazorat_to": 6,  "nazorat_to_pct": 5},
          {"label": "Yaxshi",     "grade": 4, "tajriba_tb": 44, "tajriba_tb_pct": 31, "tajriba_to": 75, "tajriba_to_pct": 54, "nazorat_tb": 51, "nazorat_tb_pct": 38, "nazorat_to": 54, "nazorat_to_pct": 40},
          {"label": "Qoniqarli",  "grade": 3, "tajriba_tb": 56, "tajriba_tb_pct": 40, "tajriba_to": 52, "tajriba_to_pct": 37, "nazorat_tb": 57, "nazorat_tb_pct": 42, "nazorat_to": 58, "nazorat_to_pct": 43},
          {"label": "Qoniqarsiz", "grade": 2, "tajriba_tb": 32, "tajriba_tb_pct": 23, "tajriba_to": 0,  "tajriba_to_pct": 0,  "nazorat_tb": 23, "nazorat_tb_pct": 17, "nazorat_to": 17, "nazorat_to_pct": 12}
        ],
        "stats": {"chi2_start": 3.20, "chi2_end": 23.24, "mean_tajriba": 3.72, "mean_nazorat": 3.36, "eta": 1.11, "improvement_pct": 13}
      }
    ],
    "totals": {
      "tajriba_count": 478, "nazorat_count": 476,
      "grades": [
        {"label": "A'lo",       "grade": 5, "tajriba_tb": 25,  "tajriba_tb_pct": 5,  "tajriba_to": 44,  "tajriba_to_pct": 9,  "nazorat_tb": 17,  "nazorat_tb_pct": 3,  "nazorat_to": 18,  "nazorat_to_pct": 4},
        {"label": "Yaxshi",     "grade": 4, "tajriba_tb": 167, "tajriba_tb_pct": 35, "tajriba_to": 237, "tajriba_to_pct": 50, "nazorat_tb": 189, "nazorat_tb_pct": 40, "nazorat_to": 173, "nazorat_to_pct": 36},
        {"label": "Qoniqarli",  "grade": 3, "tajriba_tb": 191, "tajriba_tb_pct": 40, "tajriba_to": 197, "tajriba_to_pct": 41, "nazorat_tb": 190, "nazorat_tb_pct": 40, "nazorat_to": 222, "nazorat_to_pct": 47},
        {"label": "Qoniqarsiz", "grade": 2, "tajriba_tb": 95,  "tajriba_tb_pct": 20, "tajriba_to": 0,   "tajriba_to_pct": 0,  "nazorat_tb": 80,  "nazorat_tb_pct": 17, "nazorat_to": 63,  "nazorat_to_pct": 13}
      ],
      "stats": {"chi2_start": 4.17, "chi2_end": 85.38, "mean_tajriba": 3.68, "mean_nazorat": 3.31, "eta": 1.11, "improvement_pct": 11, "chi2_critical": 7.81}
    }
  }
}
```

**Route (backend/routes/api.php):**
```php
Route::get('/dashboard/research-stats', [DashboardController::class, 'researchStats']);
```

---

### 2-qadam — Frontend TypeScript Types + API

**Fayl:** `backend/resources/js/api/dashboard.ts` ga qo'shish:

```typescript
export interface ResearchGradeRow {
  label: string; grade: number;
  tajriba_tb: number; tajriba_tb_pct: number;
  tajriba_to: number; tajriba_to_pct: number;
  nazorat_tb: number; nazorat_tb_pct: number;
  nazorat_to: number; nazorat_to_pct: number;
}
export interface DistrictStats {
  chi2_start: number; chi2_end: number;
  mean_tajriba: number; mean_nazorat: number;
  eta: number; improvement_pct: number;
  chi2_critical?: number;
}
export interface ResearchDistrict {
  id: string; name: string;
  tajriba_count: number; nazorat_count: number;
  grades: ResearchGradeRow[];
  stats: DistrictStats;
}
export interface ResearchStatsData {
  districts: ResearchDistrict[];
  totals: { tajriba_count: number; nazorat_count: number; grades: ResearchGradeRow[]; stats: DistrictStats };
}

// dashboardApi obyektiga:
getResearchStats: async () => {
  const r = await apiClient.get<JSendResponse<ResearchStatsData>>('/dashboard/research-stats');
  return r.data;
},
```

---

### 3-qadam — ResearchStatsSection.tsx Komponenti

**Yangi fayl:** `backend/resources/js/components/dashboard/ResearchStatsSection.tsx`

#### UI Tuzilishi:
```
[Sarlavha: "Tadqiqot-sinov ishlari natijalari"]
[Tabs: Shumanay | Qanliko'l | Ellikqal'a | Jami (3 tuman)]

[StatCard: η=1.11] [StatCard: chi2=85.38] [StatCard: x̄=3.68] [StatCard: ȳ=3.31]

[H1 Badge: "Metodika samarali (chi2_emp > chi2_krit)"]

[Stacked BarChart — recharts]
  X: [TB Tajriba] [TO Tajriba] [TB Nazorat] [TO Nazorat]
  Y: 0-100%
  Bars: A'lo(purple) | Yaxshi(green) | Qoniqarli(amber) | Qoniqarsiz(red)

[DataTable: aniq sonlar]
[Source note]
```

#### Ranglar:
- A'lo: `#A855F7` (primary purple)
- Yaxshi: `#10B981` (primary green)
- Qoniqarli: `#F59E0B` (amber)
- Qoniqarsiz: `#EF4444` (red)

#### recharts Chart Data:
```typescript
function buildChartData(grades: ResearchGradeRow[], isPercent = true) {
  const key = isPercent ? '_pct' : '';
  return [
    {
      name: 'Tajriba\n(Boshi)',
      alo:        grades.find(g => g.grade === 5)?.[`tajriba_tb${key}`] ?? 0,
      yaxshi:     grades.find(g => g.grade === 4)?.[`tajriba_tb${key}`] ?? 0,
      qoniqarli:  grades.find(g => g.grade === 3)?.[`tajriba_tb${key}`] ?? 0,
      qoniqarsiz: grades.find(g => g.grade === 2)?.[`tajriba_tb${key}`] ?? 0,
    },
    {
      name: 'Tajriba\n(Oxiri)',
      alo:        grades.find(g => g.grade === 5)?.[`tajriba_to${key}`] ?? 0,
      yaxshi:     grades.find(g => g.grade === 4)?.[`tajriba_to${key}`] ?? 0,
      qoniqarli:  grades.find(g => g.grade === 3)?.[`tajriba_to${key}`] ?? 0,
      qoniqarsiz: grades.find(g => g.grade === 2)?.[`tajriba_to${key}`] ?? 0,
    },
    {
      name: 'Nazorat\n(Boshi)',
      alo:        grades.find(g => g.grade === 5)?.[`nazorat_tb${key}`] ?? 0,
      yaxshi:     grades.find(g => g.grade === 4)?.[`nazorat_tb${key}`] ?? 0,
      qoniqarli:  grades.find(g => g.grade === 3)?.[`nazorat_tb${key}`] ?? 0,
      qoniqarsiz: grades.find(g => g.grade === 2)?.[`nazorat_tb${key}`] ?? 0,
    },
    {
      name: 'Nazorat\n(Oxiri)',
      alo:        grades.find(g => g.grade === 5)?.[`nazorat_to${key}`] ?? 0,
      yaxshi:     grades.find(g => g.grade === 4)?.[`nazorat_to${key}`] ?? 0,
      qoniqarli:  grades.find(g => g.grade === 3)?.[`nazorat_to${key}`] ?? 0,
      qoniqarsiz: grades.find(g => g.grade === 2)?.[`nazorat_to${key}`] ?? 0,
    },
  ];
}
```

---

### 4-qadam — DashboardPage.tsx Integratsiya

```tsx
// Import qo'shish:
import { ResearchStatsSection } from '@/components/dashboard/ResearchStatsSection';

// Query qo'shish:
const { data: researchRes, isLoading: researchLoading } = useQuery({
  queryKey: ['dashboard-research-stats'],
  queryFn: dashboardApi.getResearchStats,
  staleTime: 1000 * 60 * 60, // 1 soat (static data)
});

// JSX da (recent_attempts GlassCard pastida):
{!researchLoading && researchRes?.data && (
  <ResearchStatsSection data={researchRes.data} />
)}
```

---

### 5-qadam — i18n Kalitlari (3 til)

**uz.json, ru.json, en.json** ga `research_stats` kalit qo'shish.

---

### 6-qadam — Build va Tekshirish

```bash
cd backend && npm run build
```

Tekshirish ro'yxati:
- [ ] `/api/v1/dashboard/research-stats` 200 qaytaradi
- [ ] Dashboard da "Tadqiqot natijalari" bo'limi ko'rinadi
- [ ] Tab almashtirganda chart va jadval yangilanadi
- [ ] eta, chi2, x, y kartlari to'g'ri raqamlarni ko'rsatadi
- [ ] Stacked bar foizlar to'g'ri
- [ ] Mobile responsive
- [ ] Dark mode ishlaydi
- [ ] 3 tilda matnlar to'g'ri

---

## Ta'sirlangan Fayllar

### Yangi:
- `backend/resources/js/components/dashboard/ResearchStatsSection.tsx`

### O'zgartirilgan:
- `backend/app/Http/Controllers/Api/DashboardController.php`
- `backend/routes/api.php`
- `backend/resources/js/api/dashboard.ts`
- `backend/resources/js/pages/DashboardPage.tsx`
- `backend/resources/js/i18n/locales/uz.json`
- `backend/resources/js/i18n/locales/ru.json`
- `backend/resources/js/i18n/locales/en.json`

---

## Taxminiy Vaqt

| Qadam | Vaqt |
|-------|------|
| Backend endpoint | ~20 daqiqa |
| TypeScript types + API | ~15 daqiqa |
| ResearchStatsSection komponenti | ~60 daqiqa |
| DashboardPage integratsiya | ~10 daqiqa |
| i18n kalitlari | ~15 daqiqa |
| Build + test | ~15 daqiqa |
| **Jami** | **~2.5 soat** |

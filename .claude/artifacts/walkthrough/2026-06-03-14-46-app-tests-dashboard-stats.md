# Walkthrough - Ilova testlari va statistika

Ushbu hujjatda admin panelning "Ilova testlari" sahifasida statistikalarni ko'rsatish va ma'lumotlar bazasida o'quvchilarning test topshirish (attempts) ma'lumotlarini to'ldirish ishlari tavsiflanadi.

## Amalga oshirilgan ishlar

1. **Ma'lumotlar bazasini to'ldirish (Seeding)**:
   - Yangi `QuizAttemptSeeder` seeder yaratildi.
   - Bazadagi barcha student o'quvchilar (`role = user`) uchun tasodifiy darsga bog'lanmagan testlarni topshirish urinishlari va variant tanlovlari (attempts & answers) generatsiya qilindi.
   - Baholar va topshirish sanalari (o'quv yilining boshlanishi va oxiri oraliqlarida) mos ravishda realistik shakllantirildi.
   - Jami **2167 ta topshirish urinishi** va ularga mos javoblar bazaga kiritildi.

2. **Frontend API (dashboard.ts)**:
   - `StudentResultsData` interface tiplari frontendga qo'shildi.
   - `/api/v1/dashboard/student-results` endpointini so'rash uchun `getStudentResults` API funksiyasi yaratildi.

3. **UI o'zgarishlari (AppTestsPage.tsx)**:
   - Sahifa yuklanganda `getStudentResults({ academic_year: 'all' })` orqali tizimdagi global test urinishlari statistikalari chaqirib olindi.
   - "Kimyo" va "Geografiya" tablari yoniga uchta premium Glassmorphism ko'rinishidagi KPI kartalar qo'shildi:
     - **Jami topshirishlar**: Tizimdagi testlar topshirilgan umumiy urinishlar soni.
     - **Noodatiy o'quvchilar**: Test topshirgan noyob o'quvchilar soni.
     - **O'rtacha natija**: O'rtacha to'g'ri topilgan javoblar foizi.

4. **Tarjimalar**:
   - `uz.json`, `ru.json`, va `en.json` fayllariga `"summary_avg_score"` kaliti qo'shildi.

## O'zgarishlar diffi

### API va Tiplar (`resources/js/api/dashboard.ts`)
```typescript
export interface StudentResultsData {
  filters: {
    academic_year: string;
    from: string | null;
    to: string | null;
    school_id: number | null;
    lang_id: number;
  };
  summary: {
    total_attempts: number;
    unique_students: number;
    avg_percent: number | null;
  };
  // ...
}

export const dashboardApi = {
  // ...
  getStudentResults: async (params?: { academic_year?: string; school_id?: number; lang_id?: number }) => {
    // ...
  }
};
```

### UI Dizayn (`resources/js/pages/appTests/AppTestsPage.tsx`)
```tsx
const { data: resultsData, isLoading: resultsLoading } = useQuery({
  queryKey: ['student-results-summary'],
  queryFn: () => dashboardApi.getStudentResults({ academic_year: 'all' }),
});
```

Tablar yoniga flex orqali joylashtirilgan glassmorphism KPI kartalari:
```tsx
<div className="grid grid-cols-1 gap-3 sm:grid-cols-3 lg:flex-1 lg:max-w-3xl">
  {/* KPI Cards: Jami topshirishlar, Noodatiy o'quvchilar, O'rtacha natija */}
</div>
```

## Tekshirish va testlash

1. `npm run build` muvaffaqiyatli bajarildi (TypeScript error va kompilyatsiya xatolarisiz).
2. Tizim ishga tushirilganda "Ilova testlari" sahifasida KPI kartalari to'g'ri chiqmoqda va real vaqtdagi bazadagi attempts ma'lumotlarini hisoblab ko'rsatmoqda.

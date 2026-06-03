# Walkthrough - Foydalanuvchilar ro'yxati paginatsiyasi

Ushbu hujjatda `/users` sahifasida foydalanuvchilar ro'yxatini paginatsiya (sahifalarga bo'lish) tizimi joriy qilinganligi tavsiflanadi.

## Amalga oshirilgan ishlar

1. **Pagination logic va holatlari (UsersPage.tsx)**:
   - `currentPage` va `pageSize` (sahifadagi yozuvlar soni: 15 ta) o'zgaruvchilari kiritildi.
   - Paginatsiya avtomatik tarzda o'quvchi qidirganda (`userSearch`), viloyat (`filterCity`) yoki maktab (`filterSchoolId`) bo'yicha filtrlaganda birinchi sahifaga qaytadigan (`setCurrentPage(1)`) qilindi.
   - `filteredUsers` ro'yxatidan faqat joriy sahifadagi 15 ta o'quvchini kesib ko'rsatadigan `paginatedUsers` `useMemo` orqali shakllantirildi.
   - Sahifa raqamlarini hisoblaydigan va ko'p sahifa bo'lsa ellipslar (`...`) bilan qisqartiradigan `pageNumbers` yordamchi algoritm qo'shildi (masalan: `[1, '...', 4, 5, 6, '...', 10]`).

2. **UI/UX Paginatsiya paneli (UsersPage.tsx)**:
   - Table oxiriga premium Glassmorphism ko'rinishidagi paginatsiya boshqaruvlari joylashtirildi:
     - Chap tomonda hozirgi sahifadagi yozuvlar diapazoni va umumiy soni ko'rsatildi (masalan: `430 tadan 1-15 ko'rsatilmoqda`).
     - O'ng tomonda "Oldingi", sahifa raqamlari va "Keyingi" tugmalari joylashtirildi.
     - Birinchi va oxirgi sahifalarda "Oldingi"/"Keyingi" tugmalari o'chirib qo'yiladigan (`disabled`) qilindi.
     - `ChevronLeft` va `ChevronRight` belgilari import qilinib, dizaynga moslashtirildi.

3. **Tarjimalar (uz.json, ru.json, en.json)**:
   - Har bir tildagi translation fayllariga `"showing_info"`, `"prev"`, va `"next"` kalitlari qo'shildi.

## O'zgarishlar diffi

### UI O'zgarishlar (`resources/js/pages/users/UsersPage.tsx`)
```tsx
const [currentPage, setCurrentPage] = useState(1);
const pageSize = 15;

// Reset page to 1 on filter
useEffect(() => {
  setCurrentPage(1);
}, [userSearch, filterCity, filterSchoolId]);

const paginatedUsers = useMemo(() => {
  return filteredUsers.slice((currentPage - 1) * pageSize, currentPage * pageSize);
}, [filteredUsers, currentPage, pageSize]);
```

Paginatsiya tugmalari:
```tsx
{totalPages > 1 && (
  <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between border-t border-white/10 dark:border-white/10 px-6 py-4">
    <p className="text-sm text-app-muted">
      {t('common.showing_info', {
        from: (currentPage - 1) * pageSize + 1,
        to: Math.min(currentPage * pageSize, filteredUsers.length),
        total: filteredUsers.length,
      })}
    </p>
    <div className="flex items-center gap-1.5 self-center">
      {/* Prev, Page numbers, Next buttons */}
    </div>
  </div>
)}
```

## Tekshirish va testlash

1. `npm run build` muvaffaqiyatli bajarildi (TypeScript compile xatolarisiz).
2. Qidiruv va tuman/maktab filtrlari o'zgartirilganda paginatsiya sahifasi avtomatik tarzda `1` ga qaytishi va to'g'ri kesmalarni chiqarishi tekshirildi.

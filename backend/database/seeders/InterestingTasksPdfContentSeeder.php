<?php

namespace Database\Seeders;

use App\Models\InterestingTask;
use App\Models\TaskQuestion;
use App\Models\TaskSubmission;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * qt.pdf dagi "qiziqarli topshiriqlar" mazmuni (matn qismi).
 * Qayta ishga tushirganda faqat «interesting» turidagi mavzular qayta yuklanadi; loyiha mazmuniga tegilmaydi.
 */
class InterestingTasksPdfContentSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function (): void {
            $interestingIds = InterestingTask::query()
                ->where('task_kind', InterestingTask::KIND_INTERESTING)
                ->pluck('id');
            if ($interestingIds->isNotEmpty()) {
                TaskSubmission::whereIn('task_id', $interestingIds)->delete();
                TaskQuestion::whereIn('task_id', $interestingIds)->delete();
                InterestingTask::whereIn('id', $interestingIds)->delete();
            }

            $tasks = $this->taskDefinitions();
            foreach ($tasks as $sortOrder => $def) {
                $task = InterestingTask::create([
                    'title'       => $def['title'],
                    'description' => $def['description'] ?? null,
                    'is_active'   => true,
                    'sort_order'  => $sortOrder,
                    'task_kind'   => InterestingTask::KIND_INTERESTING,
                ]);

                foreach ($def['questions'] as $qOrder => $body) {
                    TaskQuestion::create([
                        'task_id'       => $task->id,
                        'body'          => $body,
                        'sort_order'    => $qOrder,
                        'question_type' => TaskQuestion::TYPE_TEXT,
                    ]);
                }
            }
        });
    }

    /**
     * @return array<int, array{title: string, description?: string|null, questions: list<string>}>
     */
    private function taskDefinitions(): array
    {
        return [
            [
                'title' => 'Na va K metallari mavzusi uchun qiziqarli topshiriqlar',
                'description' => 'Kimya 8–9 sinf, ishqoriy metallar',
                'questions' => [
                    "Ishqoriy metallar yumshoq bo‘lib, ularni osonlik bilan kesib yoki shakllantirib bo‘ladi. Yumshoqlikning sababi haqida o‘z fikringizni yozing.",
                    "Ma'lumotlarni to‘g‘ri bog‘lang: chap tomondagi 1—7 raqamlar uchun o‘ng tomondagi a—g variantlaridan birini tanlang va javobni jadval shaklida yozing (masalan: 1—c, 2—e, ...).\n\n"
                    . "Chap qatorlar:\n"
                    . "1) Na\n2) Natriy gidroksid\n3) NaOH\n4) K\n5) asoslar\n6) H2S\n7) K₂O₄ va KO₂\n\n"
                    . "Variantlar (harflar):\n"
                    . "a) Rangsiz, o‘tkir (palag'da bo‘lgan tuxumni eslatuvchi) hidli, zagarli gaz.\n"
                    . "b) Peroksidlar\n"
                    . "c) Kimyoviy birikmalarida +1 oksidlanish darajasini namoyon qiladi\n"
                    . "d) Amaliyotda kaustik soda deb ham nomlanadi\n"
                    . "e) Sanoatda osh tuzi eritmasini elektroliz qilinib olinadi\n"
                    . "f) Arabcha «alkali» ishqor manosini bildiradi\n"
                    . "g) Lakmusni ko‘k rangga, fenolftaleinni pushti rangga kiritadi",
                ],
            ],
            [
                'title' => 'Ca va Mg metallari mavzusi uchun qiziqarli topshiriqlar',
                'description' => 'Kalsiy va magnesiy',
                'questions' => [
                    'Qattiq suv tarkibida Ca²⁺ va Mg²⁺ ionlari mavjud. Qattiq suv tushunchasini izohlang.',
                    'Qoraqalpog‘iston hududidagi tabiiy zaxiralardan foydalanib, tarkibida Ca va Mg ga boy minerallarni aniqlang.',
                    'Sovuq suv bilan sekin reaksiyaga kirishadigan metall qaysi?',
                    'Yonishda juda yorqin oq nur chiqaradigan metall qaysi?',
                    'Qoraqalpog‘istondagi ohaktosh konining kimyoviy tarkibi va undan qanday mahsulotlar olinishini yozing.',
                ],
            ],
            [
                'title' => '«Suvning qattiqligi va uni yumshatish usullari» mavzusi uchun qiziqarli topshiriqlar',
                'description' => null,
                'questions' => [
                    'Qoraqalpog‘iston hududidagi geologik sharoitni hisobga olgan holda, aholi punktlarida suv qattiqligining yuzaga kelish sabablari hamda uning maishiy oqibatlarini (ko‘pik chiqmasligi, nakip hosil bo‘lishi) kimyoviy jihatdan tushuntiring.',
                    'Qattiq suv faqat Mg²⁺ ionlaridan iborat. Bu to‘g‘ri deb hisoblaysizmi? Izohlang.',
                    'Qaynatish barcha qattiqlikni yo‘qotadi. Bu to‘g‘ri deb hisoblaysizmi? Izohlang.',
                ],
            ],
            [
                'title' => '«Temir» mavzusi bo‘yicha qiziqarli topshiriqlar',
                'description' => 'PDFda berilgan rasmlarga tayanib javob bering (ilovada rasm yo‘q — mavzu kontekstida yozing).',
                'questions' => [
                    'Rasmda berilgan modda (qizil kukun) Qoraqalpog‘iston hududidagi tabiiy zaxiralardan biri sifatida qaraladi. Ushbu moddaning kimyoviy tarkibini aniqlang va uning suv tarkibiga hamda texnik jarayonlarga ta’sirini tushuntiring.',
                    'Rasmda ko‘rsatilgan po‘lat simlar ishlab chiqarish uchun zarur bo‘lgan xomashyo Qoraqalpog‘iston hududidagi qaysi tabiiy zaxiralarga bog‘liq? Ushbu metallning olinishi va uning xossalarini kimyoviy jihatdan tushuntiring.',
                ],
            ],
            [
                'title' => '«Qotishmalar» mavzusi bo‘yicha qiziqarli topshiriqlar',
                'description' => null,
                'questions' => [
                    'Bo‘sh joyni to‘ldiring: ________________ — temir va uglerodning (odatda 0,02–2%) qotishmasi bo‘lib, yuqori mexanik xossalarga va elastiklikka ega hamda sanoatning har xil tarmoqlarida keng qo‘llaniladi.',
                    'Rasmda tasvirlangan buyum «Qotishmalar» mavzusi bilan qanday bog‘liq? Ushbu buyum qanday qotishmadan tayyorlanganini tushuntiring.',
                ],
            ],
            [
                'title' => '«Ishqoriy metallar» mavzusi bo‘yicha qiziqarli topshiriqlar',
                'description' => null,
                'questions' => [
                    'Rasmda berilgan elementlar (Ar, H, Na, K) orasidan eng yengil gaz va eng yengil metallni aniqlang hamda ularning Qoraqalpog‘iston hududidagi tabiiy uchraydigan shakllarini tushuntiring.',
                    'Suv osti kemalarida kislorod (O₂) olish uchun ishlatiladigan regeneratsiya reaksiyasini yozing.',
                    'Qoraqalpog‘iston hududida uchraydigan mirabilit mineralining tarkibiga kiruvchi ishqoriy metallni aniqlang va uning kimyoviy formulasini yozing.',
                ],
            ],
            [
                'title' => '«Metallarning tabiatda tarqalishi, olinishi va ishlatilishi» mavzusi bo‘yicha qiziqarli topshiriqlar',
                'description' => 'So‘zlardan to‘ldiring (krossvord) va moslik',
                'questions' => [
                    "Crossword / so‘z o‘yini (PDF dagi jadval):\n"
                    . "  K A U B E R I T O K\n"
                    . "  S U A O I K L P T L\n"
                    . "  I S L SH Z A A 2O R A\n"
                    . "  L T G T U R N T O Z\n"
                    . "  V I K S O 3D A A SH 4A\n"
                    . "  I N I T 1S E L I T R\n\n"
                    . 'Ushbu tarmoqlar yordamida topilgan formula yoki tushunchalarni yozing.',

                    "Quyidagi tuz va formular bilan nomini yozing:\n"
                    . "1) NaCl — osh tuzi\n"
                    . "2) NaOH — kaustik soda\n"
                    . "3) NaNO₃ — selitra\n"
                    . "4) KCl·NaCl — silvinit\n"
                    . "5) KCl·MgCl₂·6H₂O — karnalit\n"
                    . "6) Na₂SO₄·10H₂O — glauber tuzi\n"
                    . "7) K₂O·Al₂O₃·6SiO₂ — ortoklaz\n"
                    . "8) K₂CO₃ — potash\n\n"
                    . 'Har bir qator uchun qisqacha tushuntirish bering (ixtiyoriy).',

                    "Moslikni toping (reaksiya — mahsulotlar / xom ashyo):\n"
                    . "1) CaCO₃ + SiO₂ → ?\n"
                    . "2) Na₂CO₃ + SiO₂ → ?\n"
                    . "3) CaCO₃ + Na₂CO₃ + 6SiO₂ → ?\n"
                    . "4) Sement ishlab chiqarish uchun xom ashyo?\n"
                    . "5) CaCO₃ + K₂CO₃ + 6 SiO₂ → ?\n\n"
                    . 'Javoblaringizda harflar (a, b, c, d, e) yoki to‘g‘ri formulalar bilan yozing.',
                ],
            ],
            [
                'title' => '«Soda ishlab chiqarish» mavzusi bo‘yicha qiziqarli topshiriqlar',
                'description' => 'Leblanc va Solvay usullari, Qo‘ng‘irot soda zavodi',
                'questions' => [
                    "Berilgan jarayonlardan qaysilari Leblanc (Solve) usuliga, qaysilari ammiakli (Solvay) usuliga tegishli ekanligini aniqlang (+ belgisi qo‘ying). So‘ng Qo‘ng‘irot soda zavodida qo‘llaniladigan ammiakli usulning texnologik ketma-ketligini raqamlar bilan belgilang.\n\n"
                    . "№ | Jarayon qisqacha\n"
                    . "1 | Natriy sulfatining ko‘mir bilan qizdirib, natriy sulfidga aylantirilishi\n"
                    . "2 | To‘yintirilgan eritmaga bosim ostida karbonat angidrid yuborish\n"
                    . "3 | Hosil bo‘gan sodani ajratib olish uchun qattiq aralashma maxsus tegirmonda maydalanadi\n"
                    . "4 | Osh tuzining sulfat kislota yordamida natriy sulfatga o‘tkazilishi\n"
                    . "5 | Hosil bo‘ladigan ammiak bilan osh tuzining konsentrlangan eritmasi to‘yinishi\n"
                    . "6 | Eritma sovutiladi\n"
                    . "7 | Natriy sulfidi kukun holida ohaktosh bilan qizdirilishi\n"
                    . "8 | Tegirmonda maydalanilgandan keyin suvda eritilishi\n"
                    . "9 | Kalsiy sulfidining suvda yomon erishiga bog‘liq eritma undan ajratilib, bug‘latiladi va soda kristallari olinadi\n"
                    . "10 | Sovuq eritmadan yomon eriydigan natriy gidrokarbonatning cho‘kmaga tushishi\n"
                    . "11 | Cho‘kmaga tushgan natriy gidrokarbonatning qizdirilishi\n"
                    . "12 | Bu yerda CO₂, CS₂ lar gidrolizga uchraydi\n"
                    . "13 | Ammoniy xloridning so‘ndirilgan ohak bilan qayta ishlashi\n"
                    . "14 | Natijada H₂S oson ajralib chiqadi\n\n"
                    . 'Jadvalni to‘ldiring va ketma-ketlikni yozing (masalan: 5 → 2 → 6 → ...).',
                ],
            ],
        ];
    }
}

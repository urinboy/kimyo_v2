<?php

namespace Database\Seeders;

use App\Models\AppSetting;
use App\Models\AuthorExperience;
use App\Models\Language;
use Illuminate\Database\Seeder;

class AppSettingSeeder extends Seeder
{
    private const APP_VERSION = 'v2.5.13';

    private const APP_VERSION_CODE = 26;

    /**
     * @var array<string, string>
     */
    private const DESCRIPTION_COLUMN_BY_LANG = [
        'uz' => 'description_uz',
        'ru' => 'description_ru',
        'en' => 'description_en',
        'kaa' => 'description_kaa',
    ];

    public function run(): void
    {
        $existing = AppSetting::query()->first();

        if ($existing !== null) {
            $existing->update([
                'app_version' => self::APP_VERSION,
                'app_version_code' => self::APP_VERSION_CODE,
            ]);

            return;
        }

        AppSetting::create([
            'app_version' => self::APP_VERSION,
            'app_version_code' => self::APP_VERSION_CODE,

            // Author info from screenshot
            'author_name' => 'Bekimbetova Gulnaz Nabatovna',
            'author_role' => 'Kimyo fani o\'qituvchisi',
            'author_image' => 'authors/author.png',
            'author_birth_date' => '26.04.1981',
            'author_birth_place' => 'Qonliko\'l tumani',
            'author_nationality' => 'Qoraqalpoq',
            'author_education' => 'Oliy',
            'author_specialization' => 'Kimyo',
            'author_languages' => 'Rus tili, Turk tili',
            'author_work_position' => 'Katta o\'qituvchi',
            'author_work_organization' => 'Nukus davlat texnika universiteti',
            
            // App info
            'about_app_uz' => 'Kimyo fani bo\'yicha interaktiv o\'quv qo\'llanmasi. Ilova orqali siz kimyoviy elementlar, reaksiyalar va laboratoriya ishlari bilan tanishishingiz mumkin.',
            'about_app_ru' => 'Интерактивное учебное пособие по химии. С помощью приложения вы можете ознакомиться с химическими элементами, реакциями и лабораторными работами.',
            'about_app_en' => 'Interactive educational guide for chemistry. Through the app, you can learn about chemical elements, reactions, and laboratory work.',
            'privacy_policy_url' => 'https://kimyo.uz/privacy',
            'terms_url' => 'https://kimyo.uz/terms',
        ]);

        $this->seedAuthorExperiences();

        // Additional info from screenshot
        $additional = [
            ['key_uz' => 'Ilmiy daraja', 'value_uz' => 'Yo\'q', 'order' => 1],
            ['key_uz' => 'Ilmiy unvon', 'value_uz' => 'Yo\'q', 'order' => 2],
            ['key_uz' => 'Davlat mukofotlari', 'value_uz' => 'Yo\'q', 'order' => 3],
            ['key_uz' => 'Deputatlik', 'value_uz' => 'Yo\'q', 'order' => 4],
        ];

        foreach ($additional as $info) {
            \App\Models\AuthorAdditionalInfo::create($info);
        }
    }

    /**
     * Tillar jadvalidagi `languages` (faqat `is_active`) bo‘yicha `description_*` maydonlarni to‘ldiradi.
     */
    private function seedAuthorExperiences(): void
    {
        $activeCodes = Language::query()
            ->where('is_active', true)
            ->orderBy('id')
            ->pluck('code')
            ->all();

        if ($activeCodes === []) {
            return;
        }

        $rows = $this->authorExperienceTranslatableRows();

        foreach ($rows as $row) {
            $data = [
                'years' => $row['years'],
                'order' => $row['order'],
            ];
            $texts = $row['text'];

            foreach ($activeCodes as $code) {
                $code = (string) $code;
                if (! isset(self::DESCRIPTION_COLUMN_BY_LANG[$code]) || ! \array_key_exists($code, $texts)) {
                    continue;
                }
                $value = $texts[$code];
                if ($value === null || $value === '') {
                    continue;
                }
                $data[self::DESCRIPTION_COLUMN_BY_LANG[$code]] = $value;
            }

            if (empty($data['description_uz'] ?? null) && ! empty($texts['uz'])) {
                $data['description_uz'] = $texts['uz'];
            }

            AuthorExperience::query()->create($data);
        }
    }

    /**
     * Barcha tillar matnlari; til jadvalida qaysi `code` bo‘lsa, shu colonka yaratiladi.
     *
     * @return list<array{years: string, order: int, text: array<string, string>}>
     */
    private function authorExperienceTranslatableRows(): array
    {
        return [
            [
                'years' => '2006-2015',
                'order' => 1,
                'text' => [
                    'uz' => 'Shumanay tumani 7-son maktab o\'qituvchisi',
                    'ru' => 'Учитель 7-й школы Шуманайского района',
                    'en' => 'Teacher at secondary school No. 7, Shumanay district',
                    'kaa' => 'Shumanay rayoni 7-nomer mektebi oqıtıwcısı',
                ],
            ],
            [
                'years' => '2015-2023',
                'order' => 2,
                'text' => [
                    'uz' => 'Shumanay tumani XTB tabiiy fanlar metodisti',
                    'ru' => 'Методист естественных наук отдела народного образования Шуманайского района',
                    'en' => 'Natural sciences methodologist, Shumanay district public education department',
                    'kaa' => 'Shumanay rayoni XTB tabiiy pánler metodisti',
                ],
            ],
            [
                'years' => '2023 (iyun-sentabr)',
                'order' => 3,
                'text' => [
                    'uz' => '3-son maktab direktor o\'rinbosari',
                    'ru' => 'Заместитель директора 3-й школы',
                    'en' => 'Deputy director of secondary school No. 3',
                    'kaa' => '3-nomer mektep direktor ornıbasarı',
                ],
            ],
            [
                'years' => '2023-2025',
                'order' => 4,
                'text' => [
                    'uz' => 'Nukus Konchilik instituti, kimyo fani stajyor o\'qituvchisi',
                    'ru' => 'Стажёр-преподаватель химии Нукусского горно-металлургического института',
                    'en' => 'Trainee chemistry teacher, Nukus Mining and Metallurgical Institute',
                    'kaa' => 'Nókis Gornı metalurgiya institutı, ximiya pańi stajyor oqıtıwcısı',
                ],
            ],
            [
                'years' => '2025-hozir',
                'order' => 5,
                'text' => [
                    'uz' => 'Nukus davlat texnika universiteti katta o\'qituvchi',
                    'ru' => 'Старший преподаватель Нукусского государственного технического университета',
                    'en' => 'Senior lecturer, Nukus State Technical University',
                    'kaa' => 'Nókis mámleketlik texnika universiteti úlken oqıtıwcısı',
                ],
            ],
        ];
    }
}

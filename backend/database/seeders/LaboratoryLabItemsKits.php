<?php

namespace Database\Seeders;

use App\Models\LessonLabItem;

/**
 * 6–16-laboratoriyalar (Lesson tartibi 1–11) uchun virtual laboratoriya elementlari.
 */
final class LaboratoryLabItemsKits
{
    /**
     * @return list<list<array<string, mixed>>>
     */
    public static function allKits(): array
    {
        return [
            self::kit6(),
            self::kit7(),
            self::kit8(),
            self::kit9(),
            self::kit10(),
            self::kit11(),
            self::kit12(),
            self::kit13(),
            self::kit14(),
            self::kit15(),
            self::kit16(),
        ];
    }

    /**
     * @return list<array<string, mixed>>
     */
    private static function baseItem(array $row): array
    {
        return array_merge([
            'is_required' => true, 'is_active' => true,
        ], $row);
    }

    /** 6: tuzlar + metallar */
    private static function kit6(): array
    {
        $catE = LessonLabItem::CATEGORY_EQUIPMENT;
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;
        $catEl = LessonLabItem::CATEGORY_ELEMENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar (tajriba uchun)', 'quantity' => '3', 'unit' => 'dona', 'notes' => 'Har bir eritma va metall juftligi alohida probirkada.', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Kumush (I)-nitrat eritmasi', 'formula' => 'AgNO₃', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'Birinchi probirkaga.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Mis (II)-sulfat eritmasi', 'formula' => 'CuSO₄', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'Ikkinchi probirkaga.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Qo‘rg‘oshin (II)-nitrat eritmasi', 'formula' => 'Pb(NO₃)₂', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'Uchinchi probirkaga.', 'sort_order' => 4]),
            self::baseItem(['category' => $catEl, 'name' => 'Mis simi', 'formula' => 'Cu', 'quantity' => '1', 'unit' => 'bo‘lak', 'notes' => 'AgNO₃ bilan juftlashtiriladi.', 'sort_order' => 5]),
            self::baseItem(['category' => $catEl, 'name' => 'Temir kukuni', 'formula' => 'Fe', 'quantity' => 'oz', 'unit' => 'g', 'notes' => 'CuSO₄ bilan juftlashtiriladi.', 'sort_order' => 6]),
            self::baseItem(['category' => $catEl, 'name' => 'Mis kukuni', 'formula' => 'Cu', 'quantity' => 'oz', 'unit' => 'g', 'notes' => 'Pb(NO₃)₂ bilan juftlashtiriladi.', 'sort_order' => 7]),
            self::baseItem(['category' => $catE, 'name' => 'Eslatma (virtual laboratoriya)', 'quantity' => '1', 'unit' => '—', 'notes' => 'Ikki moddani tanlang — siljish va cho‘kma reaksiyalari avtomatik aniqlanadi.', 'sort_order' => 8, 'is_required' => false]),
        ];
    }

    /** 7: elektroliz */
    private static function kit7(): array
    {
        $catE = LessonLabItem::CATEGORY_EQUIPMENT;
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'U-simon elektrolizyer nay', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'CuCl₂ va KI tajribalari uchun.', 'sort_order' => 1]),
            self::baseItem(['category' => $catE, 'name' => 'Grafit elektrod', 'quantity' => '2', 'unit' => 'dona', 'notes' => 'Katod/anod sifatida.', 'sort_order' => 2]),
            self::baseItem(['category' => $catE, 'name' => 'Mis elektrod', 'formula' => 'Cu', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'CuCl₂ elektrolizida.', 'sort_order' => 3]),
            self::baseItem(['category' => $catE, 'name' => 'O‘zgarmas tok manbai (DC)', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Grafit + elektrolit bilan juftlang.', 'sort_order' => 4]),
            self::baseItem(['category' => $catR, 'name' => 'Mis (II)-xlorid eritmasi', 'formula' => 'CuCl₂', 'quantity' => '3/4', 'unit' => 'nay hajmi', 'notes' => 'Mis va grafit elektrod bilan elektroliz.', 'sort_order' => 5]),
            self::baseItem(['category' => $catR, 'name' => 'Kaliy yodid eritmasi (2 M)', 'formula' => 'KI', 'quantity' => '10–20', 'unit' => 'ml', 'notes' => 'Grafit elektrodlar, H₂ va yod.', 'sort_order' => 6]),
            self::baseItem(['category' => $catR, 'name' => 'Yangi tayyorlangan kraxmal eritmasi', 'quantity' => '1–2', 'unit' => 'tomcha', 'notes' => 'Yod tomonda sinov.', 'sort_order' => 7, 'is_required' => false]),
        ];
    }

    /** 8: Al + kislota / ishqor */
    private static function kit8(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;
        $catEl = LessonLabItem::CATEGORY_ELEMENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '2', 'unit' => 'dona', 'notes' => 'Alyuminiy bo‘lakchalar.', 'sort_order' => 1]),
            self::baseItem(['category' => $catEl, 'name' => 'Alyuminiy bo‘lakchalari', 'formula' => 'Al', 'quantity' => 'bir necha', 'unit' => 'dona', 'notes' => 'HCl va NaOH bilan alohida.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Xlorid kislota eritmasi', 'formula' => 'HCl', 'quantity' => '2–5', 'unit' => 'ml', 'notes' => 'Vodorod gazi ajralishi.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'O‘yuvchi natriy eritmasi', 'formula' => 'NaOH', 'quantity' => '2–5', 'unit' => 'ml', 'notes' => 'Amfoter metall — vodorod.', 'sort_order' => 4]),
        ];
    }

    /** 9: namunalar */
    private static function kit9(): array
    {
        $catE = LessonLabItem::CATEGORY_EQUIPMENT;
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;
        $catEl = LessonLabItem::CATEGORY_ELEMENT;

        return [
            self::baseItem(['category' => $catE, 'name' => 'Alyuminiy va qotishma buyumlar to‘plami uchun taglik', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Namunalarni tartibli ko‘rish uchun.', 'sort_order' => 1]),
            self::baseItem(['category' => $catE, 'name' => 'Lupa yoki kattalashtirgich', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Sirt va struktura.', 'sort_order' => 2]),
            self::baseItem(['category' => $catE, 'name' => 'Pinset', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Yengil buyumlar uchun.', 'sort_order' => 3]),
            self::baseItem(['category' => $catE, 'name' => 'Magnit', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Ferromagnit qotishmalarni ajratish.', 'sort_order' => 4]),
            self::baseItem(['category' => $catE, 'name' => 'Elektr o‘tkazuvchanlik tekshirgichi', 'quantity' => '1', 'unit' => 'to‘plam', 'notes' => 'Metall xossalari.', 'sort_order' => 5]),
            self::baseItem(['category' => $catV, 'name' => 'Petri oynasi yoki soat oynasi', 'quantity' => '4', 'unit' => 'dona', 'notes' => 'Namunalar', 'sort_order' => 6]),
            self::baseItem(['category' => $catEl, 'name' => 'Alyuminiy namunasi', 'formula' => 'Al', 'quantity' => '1', 'unit' => 'dona', 'notes' => '', 'sort_order' => 7]),
            self::baseItem(['category' => $catEl, 'name' => 'Duralumin namunasi (qotishma)', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Al asosli qotishma.', 'sort_order' => 8]),
            self::baseItem(['category' => $catR, 'name' => 'Distillangan suv', 'formula' => 'H₂O', 'quantity' => '20', 'unit' => 'ml', 'notes' => 'Yuvish.', 'sort_order' => 9, 'is_required' => false]),
            self::baseItem(['category' => $catR, 'name' => 'Filtr qog‘ozi', 'quantity' => '4', 'unit' => 'dona', 'notes' => 'Tozalash.', 'sort_order' => 10, 'is_required' => false]),
        ];
    }

    /** 10: Al(OH)₃ */
    private static function kit10(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '4', 'unit' => 'dona', 'notes' => 'Al(NO₃)₃ + NaOH, keyin cho‘kma bo‘linishi.', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Aluminiy nitrat eritmasi (0,5 M)', 'formula' => 'Al(NO₃)₃', 'quantity' => '3', 'unit' => 'tomcha', 'notes' => '', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'O‘yuvchi natriy (1 M)', 'formula' => 'NaOH', 'quantity' => '9', 'unit' => 'tomcha', 'notes' => 'Cho‘kma hosil qilish va eritish.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Xlorid kislota (1 M)', 'formula' => 'HCl', 'quantity' => '6', 'unit' => 'tomcha', 'notes' => 'Cho‘kmani eritish.', 'sort_order' => 4]),
        ];
    }

    /** 11: gidroliz / lakmus */
    private static function kit11(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '3', 'unit' => 'dona', 'notes' => 'AlCl₃, suv, qizdirish.', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Alyuminiy xlorid eritmasi', 'formula' => 'AlCl₃', 'quantity' => '3–4', 'unit' => 'ml', 'notes' => 'Lakmus — kislota muhiti (gidroliz).', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Ko‘k lakmus eritmasi', 'quantity' => '2–3', 'unit' => 'tomcha', 'notes' => 'Indikator.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Distillangan suv', 'formula' => 'H₂O', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Suyultirish.', 'sort_order' => 4, 'is_required' => false]),
        ];
    }

    /** 12: Cu(OH)₂ */
    private static function kit12(): array
    {
        $catE = LessonLabItem::CATEGORY_EQUIPMENT;
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '3', 'unit' => 'dona', 'notes' => '', 'sort_order' => 1]),
            self::baseItem(['category' => $catV, 'name' => 'Chinni tigel', 'quantity' => '1', 'unit' => 'dona', 'notes' => 'Cho‘kmani qizdirish.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Mis (II)-sulfat eritmasi', 'formula' => 'CuSO₄', 'quantity' => '2', 'unit' => 'ml', 'notes' => '', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Natriy gidroksid eritmasi', 'formula' => 'NaOH', 'quantity' => '1–2', 'unit' => 'ml', 'notes' => 'Ko‘kimtir ko‘k cho‘kma.', 'sort_order' => 4]),
            self::baseItem(['category' => $catR, 'name' => 'Xlorid kislota eritmasi', 'formula' => 'HCl', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Cho‘kma eriydi.', 'sort_order' => 5]),
            self::baseItem(['category' => $catE, 'name' => 'Filtr va vanna', 'quantity' => '1', 'unit' => 'to‘plam', 'notes' => 'Cho‘kma ajratish.', 'sort_order' => 6, 'is_required' => false]),
        ];
    }

    /** 13: Zn(OH)₂ */
    private static function kit13(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '3', 'unit' => 'dona', 'notes' => '', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Rux sulfat eritmasi (20 %)', 'formula' => 'ZnSO₄', 'quantity' => '5', 'unit' => 'ml', 'notes' => '', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Natriy gidroksid (10 %)', 'formula' => 'NaOH', 'quantity' => '5', 'unit' => 'ml', 'notes' => 'Oq cho‘kma, izbushka.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Sulfat kislota eritmasi', 'formula' => 'H₂SO₄', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Amfoter cho‘kma eriydi.', 'sort_order' => 4]),
        ];
    }

    /** 14: Cr */
    private static function kit14(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '4', 'unit' => 'dona', 'notes' => '', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Xrom (II)-xlorid eritmasi (ko‘k)', 'formula' => 'CrCl₂', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'NaOH bilan sariq cho‘kma.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Xrom (III)-oksid', 'formula' => 'Cr₂O₃', 'quantity' => '0,5', 'unit' => 'g', 'notes' => 'Yashil.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Kaliy bixromat eritmasi', 'formula' => 'K₂Cr₂O₇', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'To‘q sariq.', 'sort_order' => 4]),
            self::baseItem(['category' => $catR, 'name' => 'Natriy sulfit eritmasi', 'formula' => 'Na₂SO₃', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Bixromat bilan reduksiya.', 'sort_order' => 5]),
            self::baseItem(['category' => $catR, 'name' => 'O‘yuvchi natriy eritmasi', 'formula' => 'NaOH', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Cr(III) tuzi bilan.', 'sort_order' => 6]),
            self::baseItem(['category' => $catR, 'name' => 'Sulfat kislota eritmasi', 'formula' => 'H₂SO₄', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Cr₂O₃ eritish, bixromat uchun.', 'sort_order' => 7]),
        ];
    }

    /** 15: Fe di- / tri-gidroksid */
    private static function kit15(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '2', 'unit' => 'dona', 'notes' => '', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Temir (II)-sulfat eritmasi', 'formula' => 'FeSO₄', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'Yashil cho‘kma Fe(OH)₂.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Temir (III)-xlorid eritmasi', 'formula' => 'FeCl₃', 'quantity' => '2–3', 'unit' => 'ml', 'notes' => 'Jigarrang cho‘kma Fe(OH)₃.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'O‘yuvchi natriy', 'formula' => 'NaOH', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => '', 'sort_order' => 4]),
            self::baseItem(['category' => $catR, 'name' => 'Xlorid kislota', 'formula' => 'HCl', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Fe(OH)₂.', 'sort_order' => 5]),
            self::baseItem(['category' => $catR, 'name' => 'Sulfat kislota', 'formula' => 'H₂SO₄', 'quantity' => 'oz', 'unit' => 'ml', 'notes' => 'Fe(OH)₃.', 'sort_order' => 6]),
        ];
    }

    /** 16: Fe²⁺ / Fe³⁺ aniqlash */
    private static function kit16(): array
    {
        $catV = LessonLabItem::CATEGORY_VESSEL;
        $catR = LessonLabItem::CATEGORY_REAGENT;

        return [
            self::baseItem(['category' => $catV, 'name' => 'Probirkalar', 'quantity' => '4', 'unit' => 'dona', 'notes' => '', 'sort_order' => 1]),
            self::baseItem(['category' => $catR, 'name' => 'Temir (II)-sulfat (yangi)', 'formula' => 'FeSO₄', 'quantity' => '3–5', 'unit' => 'tomcha', 'notes' => 'Fe²⁺.', 'sort_order' => 2]),
            self::baseItem(['category' => $catR, 'name' => 'Temir (III)-xlorid', 'formula' => 'FeCl₃', 'quantity' => '2–6', 'unit' => 'tomcha', 'notes' => 'Fe³⁺.', 'sort_order' => 3]),
            self::baseItem(['category' => $catR, 'name' => 'Kaliy geksatsianferrat (III)', 'formula' => 'K₃[Fe(CN)₆]', 'quantity' => 'bir necha', 'unit' => 'tomcha', 'notes' => '«Qizil qon tuzi» — Fe²⁺.', 'sort_order' => 4]),
            self::baseItem(['category' => $catR, 'name' => 'Kaliy geksatsianferroat (II)', 'formula' => 'K₄[Fe(CN)₆]', 'quantity' => '1', 'unit' => 'tomcha', 'notes' => '«Sariq qon tuzi» — Fe³⁺.', 'sort_order' => 5]),
            self::baseItem(['category' => $catR, 'name' => 'Kaliy rodanid (0,01 M)', 'formula' => 'KSCN', 'quantity' => '5–6', 'unit' => 'tomcha', 'notes' => 'Fe³⁺ — qizil kompleks.', 'sort_order' => 6]),
        ];
    }
}

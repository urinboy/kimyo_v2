<?php

namespace Database\Seeders\Concerns;

use App\Models\Formula;
use App\Models\FormulaTranslation;
use App\Models\Language;
use App\Models\Lesson;
use App\Models\LessonTranslation;
use App\Models\Option;
use App\Models\OptionTranslation;
use App\Models\Question;
use App\Models\QuestionTranslation;

/**
 * Seeder massivlarida 1, 2, 3 kalitlari — tartib bo‘yicha uz, ru, en matnlari;
 * `languages` jadvalidagi haqiqiy id lar `code` orqali bog‘lanadi.
 * `kaa` tiliga hozircha o‘zbek (1-slot) matnidan nusxa qo‘yiladi.
 */
trait SeedsTranslatableByLanguageCode
{
    /**
     * @return array<string, int>  code => language_id
     */
    protected function languageIdsByCode(): array
    {
        $map = Language::query()->pluck('id', 'code')->all();

        foreach (['uz', 'ru', 'en'] as $code) {
            if (empty($map[$code])) {
                throw new \RuntimeException(
                    "Seeder: '{$code}' tili topilmadi. Avval LanguageSeeder ishga tushirilishi kerak."
                );
            }
        }

        return $map;
    }

    /**
     * @param  array<int, array{text: string}>  $legacy  [1 => uz, 2 => ru, 3 => en]
     */
    protected function seedQuestionTranslationRows(Question $question, array $legacy, array $byCode): void
    {
        $slotToCode = [1 => 'uz', 2 => 'ru', 3 => 'en'];

        foreach ($slotToCode as $slot => $code) {
            if (! isset($legacy[$slot], $byCode[$code]) || ! is_array($legacy[$slot])) {
                continue;
            }

            QuestionTranslation::create([
                'question_id' => $question->id,
                'language_id' => $byCode[$code],
                'text' => $legacy[$slot]['text'],
            ]);
        }

        if (isset($byCode['kaa'], $legacy[1]) && is_array($legacy[1]) && array_key_exists('text', $legacy[1])) {
            QuestionTranslation::create([
                'question_id' => $question->id,
                'language_id' => $byCode['kaa'],
                'text' => $legacy[1]['text'],
            ]);
        }
    }

    /**
     * @param  array<int, string>  $legacy  [1 => uz, 2 => ru, 3 => en]
     */
    protected function seedOptionTranslationRows(Option $option, array $legacy, array $byCode): void
    {
        $slotToCode = [1 => 'uz', 2 => 'ru', 3 => 'en'];

        foreach ($slotToCode as $slot => $code) {
            if (! isset($legacy[$slot], $byCode[$code])) {
                continue;
            }

            OptionTranslation::create([
                'option_id' => $option->id,
                'language_id' => $byCode[$code],
                'text' => (string) $legacy[$slot],
            ]);
        }

        if (isset($byCode['kaa'], $legacy[1])) {
            OptionTranslation::create([
                'option_id' => $option->id,
                'language_id' => $byCode['kaa'],
                'text' => (string) $legacy[1],
            ]);
        }
    }

    /**
     * @param  array<int, array{title: string, content: string}>  $legacy
     */
    protected function seedLessonTranslationRows(Lesson $lesson, array $legacy, array $byCode): void
    {
        $slotToCode = [1 => 'uz', 2 => 'ru', 3 => 'en'];

        foreach ($slotToCode as $slot => $code) {
            if (! isset($legacy[$slot], $byCode[$code]) || ! is_array($legacy[$slot])) {
                continue;
            }

            $t = $legacy[$slot];
            LessonTranslation::create([
                'lesson_id' => $lesson->id,
                'language_id' => $byCode[$code],
                'title' => $t['title'],
                'content' => $t['content'],
            ]);
        }

        if (isset($byCode['kaa'], $legacy[1]) && is_array($legacy[1])) {
            $t = $legacy[1];
            LessonTranslation::create([
                'lesson_id' => $lesson->id,
                'language_id' => $byCode['kaa'],
                'title' => $t['title'],
                'content' => $t['content'],
            ]);
        }
    }

    /**
     * @param  array<int, array{name: string}>  $legacy  [1 => uz, 2 => ru, 3 => en, 4 => kaa]
     */
    protected function seedFormulaTranslationRows(Formula $formula, array $legacy, array $byCode): void
    {
        $slotToCode = [1 => 'uz', 2 => 'ru', 3 => 'en', 4 => 'kaa'];

        foreach ($slotToCode as $slot => $code) {
            if (! isset($legacy[$slot], $byCode[$code]) || ! is_array($legacy[$slot])) {
                continue;
            }

            FormulaTranslation::create([
                'formula_id' => $formula->id,
                'language_id' => $byCode[$code],
                'name' => $legacy[$slot]['name'],
            ]);
        }
    }
}

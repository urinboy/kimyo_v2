<?php

namespace App\Repositories\Eloquent;

use App\Models\Quiz;
use App\Models\Question;
use App\Models\Option;
use App\Repositories\Interfaces\QuizRepositoryInterface;
use Illuminate\Support\Facades\DB;

class EloquentQuizRepository extends BaseRepository implements QuizRepositoryInterface
{
    public function __construct(Quiz $model)
    {
        parent::__construct($model);
    }

    public function findByLessonId(int $lessonId)
    {
        return $this->model->with(['questions.translations', 'questions.options.translations'])
            ->where('lesson_id', $lessonId)
            ->first();
    }

    public function syncQuestions(int $quizId, array $questions)
    {
        return DB::transaction(function () use ($quizId, $questions) {
            $quiz = $this->model->findOrFail($quizId);
            
            // Delete existing questions not in the new list (if needed)
            // For simplicity in this version, we will clear and recreate if IDs are not provided
            // But a better way is to sync by ID.
            
            foreach ($questions as $index => $qData) {
                $question = $quiz->questions()->updateOrCreate(
                    ['id' => $qData['id'] ?? null],
                    [
                        'order' => $qData['order'] ?? $index,
                        'points' => $qData['points'] ?? 1,
                    ]
                );

                // Handle Question Translations
                if (isset($qData['translations'])) {
                    foreach ($qData['translations'] as $langId => $trans) {
                        $question->translations()->updateOrCreate(
                            ['language_id' => $langId],
                            ['text' => $trans['text'], 'image_url' => $trans['image_url'] ?? null]
                        );
                    }
                }

                // Handle Options
                if (isset($qData['options'])) {
                    $existingOptionIds = [];
                    foreach ($qData['options'] as $oData) {
                        $option = $question->options()->updateOrCreate(
                            ['id' => $oData['id'] ?? null],
                            ['is_correct' => $oData['is_correct'] ?? false]
                        );
                        $existingOptionIds[] = $option->id;

                        // Handle Option Translations
                        if (isset($oData['translations'])) {
                            foreach ($oData['translations'] as $langId => $oTrans) {
                                $option->translations()->updateOrCreate(
                                    ['language_id' => $langId],
                                    ['text' => $oTrans['text']]
                                );
                            }
                        }
                    }
                    // Optional: Delete options not in the payload
                    $question->options()->whereNotIn('id', $existingOptionIds)->delete();
                }
            }
            
            return $quiz->load(['questions.translations', 'questions.options.translations']);
        });
    }
}

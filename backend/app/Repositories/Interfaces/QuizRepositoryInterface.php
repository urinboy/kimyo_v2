<?php

namespace App\Repositories\Interfaces;

interface QuizRepositoryInterface extends BaseRepositoryInterface
{
    public function findByLessonId(int $lessonId);
    public function syncQuestions(int $quizId, array $questions);
}

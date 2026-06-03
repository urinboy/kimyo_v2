<?php

namespace Database\Seeders;

use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\QuizAttemptAnswer;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class QuizAttemptSeeder extends Seeder
{
    public function run(): void
    {
        // Clean up previous attempts
        DB::table('quiz_attempt_answers')->delete();
        DB::table('quiz_attempts')->delete();

        // Get all students
        $students = User::where('role', 'user')->get();
        if ($students->isEmpty()) {
            $this->command->warn('No student users found to seed attempts for.');
            return;
        }

        // Get all standalone quizzes (lesson_id = null)
        $quizzes = Quiz::whereNull('lesson_id')->with('questions.options')->get();
        if ($quizzes->isEmpty()) {
            $this->command->warn('No standalone quizzes found to seed attempts for.');
            return;
        }

        $this->command->info('Seeding quiz attempts for ' . $students->count() . ' students...');

        DB::transaction(function () use ($students, $quizzes) {
            foreach ($students as $student) {
                // Determine academic year based on student's registration date
                $regYear = $student->created_at ? $student->created_at->year : 2024;
                
                // Set attempt date range based on registration year
                if ($regYear === 2022) {
                    $start = Carbon::create(2022, 9, 10);
                    $end = Carbon::create(2023, 5, 15);
                } elseif ($regYear === 2023) {
                    $start = Carbon::create(2023, 9, 10);
                    $end = Carbon::create(2024, 5, 15);
                } elseif ($regYear === 2024) {
                    $start = Carbon::create(2024, 9, 10);
                    $end = Carbon::create(2025, 5, 15);
                } else {
                    $start = Carbon::create(2025, 9, 10);
                    $end = Carbon::create(2026, 5, 15);
                }

                // Each student attempts between 3 and 7 random quizzes
                $attemptCount = rand(3, 7);
                $selectedQuizzes = $quizzes->random(min($attemptCount, $quizzes->count()));

                foreach ($selectedQuizzes as $quiz) {
                    $questions = $quiz->questions;
                    if ($questions->isEmpty()) {
                        continue;
                    }

                    $totalQuestions = $questions->count();
                    // Generate a realistic score (mostly passing, e.g., 40% to 100%)
                    // Let's favor better scores (70%-100%) to match the dashboard statistics
                    $scorePercent = rand(10, 100);
                    if ($scorePercent < 30) {
                        // bad day: 30% to 60%
                        $correctCount = rand(round($totalQuestions * 0.3), round($totalQuestions * 0.6));
                    } elseif ($scorePercent < 70) {
                        // average day: 60% to 85%
                        $correctCount = rand(round($totalQuestions * 0.6), round($totalQuestions * 0.85));
                    } else {
                        // good day: 85% to 100%
                        $correctCount = rand(round($totalQuestions * 0.85), $totalQuestions);
                    }
                    
                    // Cap bounds
                    $correctCount = max(0, min($correctCount, $totalQuestions));

                    // Random date within the academic year
                    $attemptTime = Carbon::createFromTimestamp(rand($start->timestamp, $end->timestamp));

                    // Create the attempt
                    $attempt = QuizAttempt::create([
                        'quiz_id' => $quiz->id,
                        'user_id' => $student->id,
                        'school_id' => $student->school_id,
                        'correct_count' => $correctCount,
                        'total_count' => $totalQuestions,
                        'created_at' => $attemptTime,
                        'updated_at' => $attemptTime,
                    ]);

                    // Determine which questions will be correct
                    $shuffledQuestionIndices = $questions->keys()->shuffle();
                    $correctIndices = $shuffledQuestionIndices->take($correctCount)->flip();

                    foreach ($questions as $index => $question) {
                        $options = $question->options;
                        if ($options->isEmpty()) {
                            continue;
                        }

                        $correctOption = $options->firstWhere('is_correct', true) ?? $options->first();
                        $incorrectOptions = $options->where('is_correct', false);

                        $isCorrect = $correctIndices->has($index);
                        
                        if ($isCorrect) {
                            $selectedOption = $correctOption;
                        } else {
                            $selectedOption = $incorrectOptions->isEmpty() ? $correctOption : $incorrectOptions->random();
                        }

                        QuizAttemptAnswer::create([
                            'quiz_attempt_id' => $attempt->id,
                            'question_id' => $question->id,
                            'option_id' => $selectedOption->id,
                            'is_correct' => $isCorrect,
                            'created_at' => $attemptTime,
                            'updated_at' => $attemptTime,
                        ]);
                    }
                }
            }
        });

        $this->command->info('Seeding quiz attempts completed successfully. Total attempts created: ' . QuizAttempt::count());
    }
}

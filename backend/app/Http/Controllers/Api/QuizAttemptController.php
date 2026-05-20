<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Language;
use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\QuizAttemptAnswer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class QuizAttemptController extends Controller
{
    /**
     * Mobil: standalone testni topshirish (har bir savol uchun tanlangan variant).
     */
    public function store(Request $request, int $id): JsonResponse
    {
        $quiz = Quiz::query()
            ->whereNull('lesson_id')
            ->where('is_active', true)
            ->with(['questions.options'])
            ->find($id);

        if (! $quiz) {
            return response()->json(['status' => 'fail', 'message' => 'Quiz topilmadi'], 404);
        }

        $user = $request->user();
        if (! $user) {
            return response()->json(['status' => 'fail', 'message' => 'Unauthorized'], 401);
        }

        $expected = $quiz->questions->count();
        $v = Validator::make($request->all(), [
            'answers' => 'required|array',
            'answers.*.question_id' => [
                'required',
                'integer',
                Rule::exists('questions', 'id')->where('quiz_id', $quiz->id),
            ],
            'answers.*.option_id' => ['required', 'integer', 'exists:options,id'],
        ]);

        $v->after(function ($validator) use ($request, $quiz, $expected) {
            $answers = $request->input('answers', []);
            if ($expected !== count($answers)) {
                $validator->errors()->add(
                    'answers',
                    "Har bir savol uchun bitta javob bo‘lishi kerak ($expected ta)."
                );
            }
            $qids = array_column($answers, 'question_id');
            if (count($qids) !== count(array_unique($qids))) {
                $validator->errors()->add('answers', 'Takroriy question_id.');
            }
            foreach ($answers as $row) {
                if (! is_array($row)) {
                    continue;
                }
                $qid = $row['question_id'] ?? null;
                $oid = $row['option_id'] ?? null;
                if (! $qid || ! $oid) {
                    continue;
                }
                $ok = $quiz->questions->firstWhere('id', $qid)?->options->contains('id', $oid);
                if (! $ok) {
                    $validator->errors()->add('answers', "Variant savolga tegishli emas (question_id=$qid).");
                    break;
                }
            }
        });

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $data = $v->validated();
        $byQuestion = collect($data['answers'])->keyBy('question_id');

        $total = 0;
        $correct = 0;
        $rows = [];

        foreach ($quiz->questions as $q) {
            $total++;
            $oid = (int) $byQuestion[$q->id]['option_id'];
            $opt = $q->options->firstWhere('id', $oid);
            $isCorrect = (bool) $opt?->is_correct;
            if ($isCorrect) {
                $correct++;
            }
            $rows[] = [
                'question_id' => $q->id,
                'option_id' => $oid,
                'is_correct' => $isCorrect,
            ];
        }

        $attempt = DB::transaction(function () use ($quiz, $user, $correct, $total, $rows) {
            $a = QuizAttempt::query()->create([
                'quiz_id'       => $quiz->id,
                'user_id'       => $user->id,
                'school_id'     => $user->school_id,
                'correct_count' => $correct,
                'total_count'   => $total,
            ]);
            foreach ($rows as $r) {
                QuizAttemptAnswer::query()->create([
                    'quiz_attempt_id' => $a->id,
                    'question_id'     => $r['question_id'],
                    'option_id'       => $r['option_id'],
                    'is_correct'      => $r['is_correct'],
                ]);
            }

            return $a;
        });

        return response()->json([
            'status' => 'success',
            'data'   => [
                'attempt_id'    => $attempt->id,
                'correct_count' => $correct,
                'total_count'   => $total,
            ],
        ], 201);
    }

    /**
     * Admin: tanlangan test bo‘yicha filtrlangan urinishlar + savollar bo‘yicha taqsimot.
     *
     * @query academic_year masalan "2025-2026" → 2025-09-01 .. 2026-05-25
     */
    public function adminReport(Request $request, int $id): JsonResponse
    {
        $admin = $request->user();
        if (! $admin || ($admin->role ?? null) !== 'admin') {
            return response()->json(['status' => 'fail', 'message' => 'Forbidden'], 403);
        }

        $quiz = Quiz::query()->whereNull('lesson_id')->find($id);
        if (! $quiz) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }

        $yearLabel = $request->query('academic_year');
        if (! is_string($yearLabel) || ! preg_match('/^(\d{4})-(\d{4})$/', $yearLabel, $m)) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['academic_year' => ['academic_year query kerak: masalan 2025-2026']],
            ], 422);
        }
        $y1 = (int) $m[1];
        $y2 = (int) $m[2];
        if ($y2 !== $y1 + 1) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['academic_year' => ["Noto‘g‘ri oraliq: ikkinchi yil birinchisidan 1 ga katta bo‘lishi kerak"]],
            ], 422);
        }

        $from = sprintf('%04d-09-01 00:00:00', $y1);
        $to = sprintf('%04d-05-25 23:59:59', $y2);

        $schoolId = $request->query('school_id');
        if ($schoolId !== null && $schoolId !== '') {
            $schoolId = (int) $schoolId;
        } else {
            $schoolId = null;
        }

        $langId = (int) $request->query('lang_id', Language::query()->where('code', 'uz')->value('id') ?? 1);

        $attemptQuery = QuizAttempt::query()
            ->where('quiz_id', $id)
            ->whereBetween('created_at', [$from, $to]);
        if ($schoolId) {
            $attemptQuery->where('school_id', $schoolId);
        }

        $attemptIds = $attemptQuery->pluck('id');
        $totalAttempts = $attemptIds->count();

        if ($totalAttempts === 0) {
            return response()->json([
                'status' => 'success',
                'data'   => [
                    'filters' => [
                        'academic_year' => $yearLabel,
                        'from'          => $from,
                        'to'            => $to,
                        'school_id'     => $schoolId,
                        'lang_id'       => $langId,
                    ],
                    'summary' => [
                        'total_attempts'  => 0,
                        'unique_students' => 0,
                    ],
                    'questions' => [],
                    'attempts'  => [],
                ],
            ]);
        }

        $uniqueStudents = (int) QuizAttempt::query()
            ->whereIn('id', $attemptIds)
            ->selectRaw('COUNT(DISTINCT user_id) as c')
            ->value('c');

        $agg = QuizAttemptAnswer::query()
            ->whereIn('quiz_attempt_id', $attemptIds)
            ->selectRaw('question_id, option_id, COUNT(*) as cnt')
            ->groupBy('question_id', 'option_id')
            ->get();

        $countsByQOpt = [];
        foreach ($agg as $row) {
            $qid = (int) $row->question_id;
            $oid = (int) $row->option_id;
            $countsByQOpt[$qid][$oid] = (int) $row->cnt;
        }

        $quiz->load([
            'questions.translations',
            'questions.options.translations',
        ]);

        $questionsOut = [];
        foreach ($quiz->questions as $q) {
            $qText = $q->translations->firstWhere('language_id', $langId)?->text
                ?? $q->translations->first()?->text
                ?? '';
            $opts = [];
            $denom = 0;
            foreach ($q->options as $opt) {
                $c = $countsByQOpt[$q->id][$opt->id] ?? 0;
                $denom += $c;
            }
            foreach ($q->options as $opt) {
                $c = $countsByQOpt[$q->id][$opt->id] ?? 0;
                $pct = $denom > 0 ? round(100 * $c / $denom, 1) : 0.0;
                $t = $opt->translations->firstWhere('language_id', $langId)?->text
                    ?? $opt->translations->first()?->text
                    ?? '';
                $opts[] = [
                    'option_id'  => $opt->id,
                    'text'       => $t,
                    'is_correct' => (bool) $opt->is_correct,
                    'count'      => $c,
                    'percent'    => $pct,
                ];
            }
            $questionsOut[] = [
                'question_id' => $q->id,
                'order'       => $q->order,
                'text'        => $qText,
                'options'     => $opts,
            ];
        }

        $attemptRows = QuizAttempt::query()
            ->whereIn('id', $attemptIds)
            ->with(['user:id,name,email,school_id', 'user.school:id,name,short_name'])
            ->orderByDesc('created_at')
            ->limit(500)
            ->get()
            ->map(function (QuizAttempt $a) {
                return [
                    'id'            => $a->id,
                    'user_name'     => $a->user?->name,
                    'user_email'    => $a->user?->email,
                    'school_name'   => $a->user?->school?->name ?? $a->user?->school?->short_name,
                    'correct_count' => $a->correct_count,
                    'total_count'   => $a->total_count,
                    'created_at'    => $a->created_at?->toIso8601String(),
                ];
            });

        return response()->json([
            'status' => 'success',
            'data'   => [
                'filters' => [
                    'academic_year' => $yearLabel,
                    'from'          => $from,
                    'to'            => $to,
                    'school_id'     => $schoolId,
                    'lang_id'       => $langId,
                ],
                'summary' => [
                    'total_attempts'   => $totalAttempts,
                    'unique_students'  => $uniqueStudents,
                ],
                'questions' => $questionsOut,
                'attempts'  => $attemptRows,
            ],
        ]);
    }
}

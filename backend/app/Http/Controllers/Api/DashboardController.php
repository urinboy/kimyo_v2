<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Element;
use App\Models\Formula;
use App\Models\Language;
use App\Models\Lesson;
use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

class DashboardController extends Controller
{
    #[OA\Get(
        path: '/api/v1/dashboard/stats',
        summary: 'Tizim statistikalarini olish',
        tags: ['Dashboard']
    )]
    #[OA\Response(
        response: 200,
        description: 'Muvaffaqiyatli javob',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', properties: [
                    new OA\Property(property: 'stats', properties: [
                        new OA\Property(property: 'total_elements', type: 'integer', example: 118),
                        new OA\Property(property: 'total_lessons', type: 'integer', example: 25),
                        new OA\Property(property: 'total_formulas', type: 'integer', example: 50),
                        new OA\Property(property: 'total_quizzes', type: 'integer', example: 10),
                        new OA\Property(property: 'total_users', type: 'integer', example: 150),
                        new OA\Property(property: 'active_languages', type: 'integer', example: 3),
                    ], type: 'object'),
                ], type: 'object'),
            ]
        )
    )]
    public function stats(): JsonResponse
    {
        $stats = [
            'total_elements' => Element::count(),
            'total_lessons' => Lesson::count(),
            'total_formulas' => Formula::count(),
            'total_quizzes' => Quiz::count(),
            'total_users' => User::count(),
            'active_languages' => Language::where('is_active', true)->count(),
        ];

        return response()->json([
            'status' => 'success',
            'data' => [
                'stats' => $stats,
            ],
        ]);
    }

    #[OA\Get(
        path: '/api/v1/dashboard/activity',
        summary: 'Oxirgi faollik (til bo‘yicha tarjima bilan)',
        tags: ['Dashboard']
    )]
    #[OA\Parameter(name: 'lang_id', in: 'query', required: false, schema: new OA\Schema(type: 'integer'))]
    #[OA\Response(response: 200, description: 'OK')]
    public function activity(Request $request): JsonResponse
    {
        $langId = (int) $request->query('lang_id', Language::query()->where('code', 'uz')->value('id') ?? 1);

        $latest_elements = Element::query()
            ->with(['translations' => fn ($q) => $q->where('language_id', $langId)])
            ->latest()
            ->take(5)
            ->get()
            ->map(function (Element $el) {
                $tr = $el->translations->first();

                return [
                    'id' => $el->id,
                    'symbol' => $el->symbol,
                    'atomic_number' => $el->atomic_number,
                    'translations' => $tr ? [['name' => $tr->name]] : [],
                ];
            });

        $latest_users = User::query()->latest()->take(5)->get();

        $latest_formulas = Formula::query()
            ->with(['translations' => fn ($q) => $q->where('language_id', $langId)])
            ->latest()
            ->take(5)
            ->get()
            ->map(function (Formula $f) {
                $tr = $f->translations->first();

                return [
                    'id' => $f->id,
                    'formula' => $f->formula,
                    'molar_mass' => $f->molar_mass,
                    'translations' => $tr ? [['name' => $tr->name]] : [],
                ];
            });

        return response()->json([
            'status' => 'success',
            'data' => [
                'latest_elements' => $latest_elements,
                'latest_users' => $latest_users,
                'latest_formulas' => $latest_formulas,
            ],
        ]);
    }

    /**
     * Admin: barcha ilova testlari (standalone quiz) urinishlari — o‘quv yili va/yoki maktab kesimida.
     *
     * @queryParam academic_year ixtiyoriy: masalan 2025-2026 yoki "all" / bo‘sh — chegarasiz
     * @queryParam school_id ixtiyoriy: maktab filtri
     * @queryParam lang_id ixtiyoriy: quiz sarlavhasi tili (uz/ru/en kodiga mos)
     */
    #[OA\Get(
        path: '/api/v1/dashboard/student-results',
        summary: 'Ilova testlari natijalari (maktab / o‘quv yili filtri)',
        tags: ['Dashboard']
    )]
    #[OA\Parameter(name: 'academic_year', in: 'query', schema: new OA\Schema(type: 'string', example: '2025-2026'))]
    #[OA\Parameter(name: 'school_id', in: 'query', schema: new OA\Schema(type: 'integer'))]
    #[OA\Parameter(name: 'lang_id', in: 'query', schema: new OA\Schema(type: 'integer'))]
    #[OA\Response(response: 200, description: 'OK')]
    #[OA\Response(response: 422, description: 'Validatsiya')]
    public function studentResults(Request $request): JsonResponse
    {
        $admin = $request->user();
        if (! $admin || ($admin->role ?? null) !== 'admin') {
            return response()->json(['status' => 'fail', 'message' => 'Forbidden'], 403);
        }

        $yearRaw = $request->query('academic_year');
        $range = $this->parseAcademicYearRange($yearRaw);
        if ($range === false) {
            return response()->json([
                'status' => 'fail',
                'data' => ['academic_year' => ['Noto‘g‘ri format. Masalan: 2025-2026 yoki all']],
            ], 422);
        }

        $v = Validator::make($request->all(), [
            'school_id' => ['sometimes', 'nullable', 'integer', 'exists:schools,id'],
        ]);
        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $schoolId = $request->filled('school_id') ? (int) $request->query('school_id') : null;
        $langId = (int) $request->query('lang_id', Language::query()->where('code', 'uz')->value('id') ?? 1);
        $lang = Language::query()->find($langId);
        $langCode = $lang?->code ?? 'uz';

        $attemptExists = DB::table('quiz_attempts as qa')
            ->join('quizzes as q', 'q.id', '=', 'qa.quiz_id')
            ->whereNull('q.lesson_id')
            ->when($range, fn ($qq) => $qq->whereBetween('qa.created_at', $range))
            ->when($schoolId, fn ($qq) => $qq->where('qa.school_id', $schoolId));

        $totals = (clone $attemptExists)
            ->selectRaw('COUNT(*) as attempts_count, COUNT(DISTINCT qa.user_id) as students_count, SUM(qa.correct_count) as correct_sum, SUM(qa.total_count) as total_sum')
            ->first();

        $attemptsCount = (int) ($totals->attempts_count ?? 0);
        $studentsCount = (int) ($totals->students_count ?? 0);
        $correctSum = (int) ($totals->correct_sum ?? 0);
        $totalSum = (int) ($totals->total_sum ?? 0);
        $avgPercent = $totalSum > 0 ? round(100 * $correctSum / $totalSum, 1) : null;

        $byQuiz = DB::table('quiz_attempts as qa')
            ->join('quizzes as q', 'q.id', '=', 'qa.quiz_id')
            ->whereNull('q.lesson_id')
            ->when($range, fn ($qq) => $qq->whereBetween('qa.created_at', $range))
            ->when($schoolId, fn ($qq) => $qq->where('qa.school_id', $schoolId))
            ->groupBy('q.id', 'q.title_uz', 'q.title_ru', 'q.title_en', 'q.sort_order')
            ->orderBy('q.sort_order')
            ->orderBy('q.id')
            ->selectRaw('q.id as quiz_id, q.title_uz, q.title_ru, q.title_en, q.sort_order, COUNT(*) as attempts_count, COUNT(DISTINCT qa.user_id) as students_count, SUM(qa.correct_count) as correct_sum, SUM(qa.total_count) as total_sum')
            ->get()
            ->map(function ($row) use ($langCode) {
                $title = $this->quizTitleFromRow($row, $langCode);
                $tSum = (int) $row->total_sum;
                $cSum = (int) $row->correct_sum;
                $pct = $tSum > 0 ? round(100 * $cSum / $tSum, 1) : null;

                return [
                    'quiz_id' => (int) $row->quiz_id,
                    'title' => $title,
                    'attempts_count' => (int) $row->attempts_count,
                    'students_count' => (int) $row->students_count,
                    'avg_percent' => $pct,
                    'correct_sum' => $cSum,
                    'total_sum' => $tSum,
                ];
            })
            ->values();

        $bySchool = DB::table('quiz_attempts as qa')
            ->join('quizzes as q', 'q.id', '=', 'qa.quiz_id')
            ->leftJoin('schools as s', 's.id', '=', 'qa.school_id')
            ->whereNull('q.lesson_id')
            ->when($range, fn ($qq) => $qq->whereBetween('qa.created_at', $range))
            ->when($schoolId, fn ($qq) => $qq->where('qa.school_id', $schoolId))
            ->groupBy('qa.school_id')
            ->orderByRaw('qa.school_id IS NULL ASC')
            ->orderBy('attempts_count', 'desc')
            ->selectRaw('qa.school_id, MAX(s.name) as school_name, MAX(s.short_name) as school_short_name, COUNT(*) as attempts_count, COUNT(DISTINCT qa.user_id) as students_count, SUM(qa.correct_count) as correct_sum, SUM(qa.total_count) as total_sum')
            ->get()
            ->map(function ($row) {
                $tSum = (int) $row->total_sum;
                $cSum = (int) $row->correct_sum;
                $pct = $tSum > 0 ? round(100 * $cSum / $tSum, 1) : null;

                return [
                    'school_id' => $row->school_id !== null ? (int) $row->school_id : null,
                    'school_name' => $row->school_name,
                    'school_short_name' => $row->school_short_name,
                    'attempts_count' => (int) $row->attempts_count,
                    'students_count' => (int) $row->students_count,
                    'avg_percent' => $pct,
                ];
            })
            ->values();

        $byGrade = DB::table('quiz_attempts as qa')
            ->join('quizzes as q', 'q.id', '=', 'qa.quiz_id')
            ->join('users as u', 'u.id', '=', 'qa.user_id')
            ->whereNull('q.lesson_id')
            ->when($range, fn ($qq) => $qq->whereBetween('qa.created_at', $range))
            ->when($schoolId, fn ($qq) => $qq->where('qa.school_id', $schoolId))
            ->groupBy('u.grade')
            ->orderByRaw('u.grade IS NULL ASC')
            ->orderBy('u.grade')
            ->selectRaw('u.grade, COUNT(*) as attempts_count, COUNT(DISTINCT qa.user_id) as students_count, SUM(qa.correct_count) as correct_sum, SUM(qa.total_count) as total_sum')
            ->get()
            ->map(function ($row) {
                $tSum = (int) $row->total_sum;
                $cSum = (int) $row->correct_sum;
                $pct = $tSum > 0 ? round(100 * $cSum / $tSum, 1) : null;

                return [
                    'grade' => $row->grade,
                    'attempts_count' => (int) $row->attempts_count,
                    'students_count' => (int) $row->students_count,
                    'avg_percent' => $pct,
                ];
            })
            ->values();

        $recentQuery = QuizAttempt::query()
            ->whereHas('quiz', fn ($q) => $q->whereNull('lesson_id'))
            ->when($range, fn ($q) => $q->whereBetween('created_at', $range))
            ->when($schoolId, fn ($q) => $q->where('school_id', $schoolId))
            ->with([
                'user:id,name,email,username,school_id,grade',
                'user.school:id,name,short_name',
                'quiz:id,title_uz,title_ru,title_en',
            ])
            ->orderByDesc('created_at')
            ->limit(100);

        $recent = $recentQuery->get()->map(function (QuizAttempt $a) use ($langCode) {
            $q = $a->quiz;

            return [
                'id' => $a->id,
                'quiz_id' => $a->quiz_id,
                'quiz_title' => $q ? $this->quizTitleFromModel($q, $langCode) : '',
                'user_name' => $a->user?->name,
                'user_username' => $a->user?->username,
                'grade' => $a->user?->grade,
                'school_name' => $a->user?->school?->name ?? $a->user?->school?->short_name,
                'correct_count' => $a->correct_count,
                'total_count' => $a->total_count,
                'percent' => $a->total_count > 0 ? round(100 * $a->correct_count / $a->total_count, 1) : null,
                'created_at' => $a->created_at?->toIso8601String(),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => [
                'filters' => [
                    'academic_year' => is_string($yearRaw) && $yearRaw !== '' ? $yearRaw : 'all',
                    'from' => $range ? $range[0] : null,
                    'to' => $range ? $range[1] : null,
                    'school_id' => $schoolId,
                    'lang_id' => $langId,
                ],
                'summary' => [
                    'total_attempts' => $attemptsCount,
                    'unique_students' => $studentsCount,
                    'avg_percent' => $avgPercent,
                ],
                'by_quiz' => $byQuiz,
                'by_school' => $bySchool,
                'by_grade' => $byGrade,
                'recent_attempts' => $recent,
            ],
        ]);
    }

    /**
     * @return array{0: string, 1: string}|null|false null = cheklovsiz; false = noto‘g‘ri yil
     */
    private function parseAcademicYearRange(mixed $yearRaw): array|null|false
    {
        if ($yearRaw === null || $yearRaw === '') {
            return null;
        }
        if (! is_string($yearRaw)) {
            return false;
        }
        $t = trim($yearRaw);
        if ($t === '' || strcasecmp($t, 'all') === 0) {
            return null;
        }
        if (! preg_match('/^(\d{4})-(\d{4})$/', $t, $m)) {
            return false;
        }
        $y1 = (int) $m[1];
        $y2 = (int) $m[2];
        if ($y2 !== $y1 + 1) {
            return false;
        }
        $from = sprintf('%04d-09-01 00:00:00', $y1);
        $to = sprintf('%04d-05-25 23:59:59', $y2);

        return [$from, $to];
    }

    private function quizTitleFromModel(Quiz $q, string $langCode): string
    {
        $t = match ($langCode) {
            'ru' => $q->title_ru,
            'en' => $q->title_en,
            default => $q->title_uz,
        };
        $t = $t ? trim((string) $t) : '';
        if ($t !== '') {
            return $t;
        }

        return trim((string) ($q->title_uz ?: $q->title_ru ?: $q->title_en ?: ''));
    }

    private function quizTitleFromRow(object $row, string $langCode): string
    {
        $q = new Quiz([
            'title_uz' => $row->title_uz ?? '',
            'title_ru' => $row->title_ru ?? '',
            'title_en' => $row->title_en ?? '',
        ]);

        return $this->quizTitleFromModel($q, $langCode);
    }

    /**
     * Dissertatsiya tadqiqot natijalari — static data (3 tuman: Shumanay, Qanliko'l, Ellikqal'a).
     */
    #[OA\Get(
        path: '/api/v1/dashboard/research-stats',
        summary: "Dissertatsiya tajriba-sinov natijalari (static)",
        tags: ['Dashboard']
    )]
    #[OA\Response(response: 200, description: 'OK')]
    public function researchStats(): JsonResponse
    {
        $data = [
            'districts' => [
                [
                    'id' => 'shumanay',
                    'name' => 'Shumanay tumani',
                    'tajriba_count' => 190,
                    'nazorat_count' => 196,
                    'grades' => [
                        ['label' => "A'lo",       'grade' => 5, 'tajriba_tb' => 12, 'tajriba_tb_pct' => 6,  'tajriba_to' => 18, 'tajriba_to_pct' => 9,  'nazorat_tb' => 10, 'nazorat_tb_pct' => 5,  'nazorat_to' => 7,  'nazorat_to_pct' => 4],
                        ['label' => 'Yaxshi',     'grade' => 4, 'tajriba_tb' => 65, 'tajriba_tb_pct' => 34, 'tajriba_to' => 85, 'tajriba_to_pct' => 45, 'nazorat_tb' => 73, 'nazorat_tb_pct' => 34, 'nazorat_to' => 66, 'nazorat_to_pct' => 34],
                        ['label' => 'Qoniqarli',  'grade' => 3, 'tajriba_tb' => 76, 'tajriba_tb_pct' => 40, 'tajriba_to' => 87, 'tajriba_to_pct' => 46, 'nazorat_tb' => 81, 'nazorat_tb_pct' => 41, 'nazorat_to' => 95, 'nazorat_to_pct' => 48],
                        ['label' => 'Qoniqarsiz', 'grade' => 2, 'tajriba_tb' => 37, 'tajriba_tb_pct' => 20, 'tajriba_to' => 0,  'tajriba_to_pct' => 0,  'nazorat_tb' => 32, 'nazorat_tb_pct' => 20, 'nazorat_to' => 28, 'nazorat_to_pct' => 14],
                    ],
                    'stats' => ['chi2_start' => 1.07, 'chi2_end' => 35.50, 'mean_tajriba' => 3.64, 'mean_nazorat' => 3.27, 'eta' => 1.11, 'improvement_pct' => 12],
                ],
                [
                    'id' => 'qanliko_l',
                    'name' => "Qanliko'l tumani",
                    'tajriba_count' => 148,
                    'nazorat_count' => 145,
                    'grades' => [
                        ['label' => "A'lo",       'grade' => 5, 'tajriba_tb' => 5,  'tajriba_tb_pct' => 3,  'tajriba_to' => 13, 'tajriba_to_pct' => 9,  'nazorat_tb' => 3,  'nazorat_tb_pct' => 2,  'nazorat_to' => 5,  'nazorat_to_pct' => 3],
                        ['label' => 'Yaxshi',     'grade' => 4, 'tajriba_tb' => 58, 'tajriba_tb_pct' => 39, 'tajriba_to' => 77, 'tajriba_to_pct' => 52, 'nazorat_tb' => 65, 'nazorat_tb_pct' => 45, 'nazorat_to' => 53, 'nazorat_to_pct' => 37],
                        ['label' => 'Qoniqarli',  'grade' => 3, 'tajriba_tb' => 59, 'tajriba_tb_pct' => 40, 'tajriba_to' => 58, 'tajriba_to_pct' => 39, 'nazorat_tb' => 52, 'nazorat_tb_pct' => 36, 'nazorat_to' => 69, 'nazorat_to_pct' => 48],
                        ['label' => 'Qoniqarsiz', 'grade' => 2, 'tajriba_tb' => 26, 'tajriba_tb_pct' => 18, 'tajriba_to' => 0,  'tajriba_to_pct' => 0,  'nazorat_tb' => 25, 'nazorat_tb_pct' => 17, 'nazorat_to' => 18, 'nazorat_to_pct' => 12],
                    ],
                    'stats' => ['chi2_start' => 1.33, 'chi2_end' => 26.91, 'mean_tajriba' => 3.70, 'mean_nazorat' => 3.31, 'eta' => 1.12, 'improvement_pct' => 13],
                ],
                [
                    'id' => 'ellikqala',
                    'name' => "Ellikqal'a tumani",
                    'tajriba_count' => 140,
                    'nazorat_count' => 135,
                    'grades' => [
                        ['label' => "A'lo",       'grade' => 5, 'tajriba_tb' => 8,  'tajriba_tb_pct' => 6,  'tajriba_to' => 13, 'tajriba_to_pct' => 9,  'nazorat_tb' => 4,  'nazorat_tb_pct' => 3,  'nazorat_to' => 6,  'nazorat_to_pct' => 5],
                        ['label' => 'Yaxshi',     'grade' => 4, 'tajriba_tb' => 44, 'tajriba_tb_pct' => 31, 'tajriba_to' => 75, 'tajriba_to_pct' => 54, 'nazorat_tb' => 51, 'nazorat_tb_pct' => 38, 'nazorat_to' => 54, 'nazorat_to_pct' => 40],
                        ['label' => 'Qoniqarli',  'grade' => 3, 'tajriba_tb' => 56, 'tajriba_tb_pct' => 40, 'tajriba_to' => 52, 'tajriba_to_pct' => 37, 'nazorat_tb' => 57, 'nazorat_tb_pct' => 42, 'nazorat_to' => 58, 'nazorat_to_pct' => 43],
                        ['label' => 'Qoniqarsiz', 'grade' => 2, 'tajriba_tb' => 32, 'tajriba_tb_pct' => 23, 'tajriba_to' => 0,  'tajriba_to_pct' => 0,  'nazorat_tb' => 23, 'nazorat_tb_pct' => 17, 'nazorat_to' => 17, 'nazorat_to_pct' => 12],
                    ],
                    'stats' => ['chi2_start' => 3.20, 'chi2_end' => 23.24, 'mean_tajriba' => 3.72, 'mean_nazorat' => 3.36, 'eta' => 1.11, 'improvement_pct' => 13],
                ],
            ],
            'totals' => [
                'tajriba_count' => 478,
                'nazorat_count' => 476,
                'grades' => [
                    ['label' => "A'lo",       'grade' => 5, 'tajriba_tb' => 25,  'tajriba_tb_pct' => 5,  'tajriba_to' => 44,  'tajriba_to_pct' => 9,  'nazorat_tb' => 17,  'nazorat_tb_pct' => 3,  'nazorat_to' => 18,  'nazorat_to_pct' => 4],
                    ['label' => 'Yaxshi',     'grade' => 4, 'tajriba_tb' => 167, 'tajriba_tb_pct' => 35, 'tajriba_to' => 237, 'tajriba_to_pct' => 50, 'nazorat_tb' => 189, 'nazorat_tb_pct' => 40, 'nazorat_to' => 173, 'nazorat_to_pct' => 36],
                    ['label' => 'Qoniqarli',  'grade' => 3, 'tajriba_tb' => 191, 'tajriba_tb_pct' => 40, 'tajriba_to' => 197, 'tajriba_to_pct' => 41, 'nazorat_tb' => 190, 'nazorat_tb_pct' => 40, 'nazorat_to' => 222, 'nazorat_to_pct' => 47],
                    ['label' => 'Qoniqarsiz', 'grade' => 2, 'tajriba_tb' => 95,  'tajriba_tb_pct' => 20, 'tajriba_to' => 0,   'tajriba_to_pct' => 0,  'nazorat_tb' => 80,  'nazorat_tb_pct' => 17, 'nazorat_to' => 63,  'nazorat_to_pct' => 13],
                ],
                'stats' => ['chi2_start' => 4.17, 'chi2_end' => 85.38, 'mean_tajriba' => 3.68, 'mean_nazorat' => 3.31, 'eta' => 1.11, 'improvement_pct' => 11, 'chi2_critical' => 7.81],
            ],
        ];

        return response()->json(['status' => 'success', 'data' => $data]);
    }
}

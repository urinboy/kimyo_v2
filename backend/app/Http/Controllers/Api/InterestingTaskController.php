<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InterestingTask;
use App\Models\TaskQuestion;
use App\Models\TaskSubmission;
use App\Models\TaskAnswer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class InterestingTaskController extends Controller
{
    // ── Admin: CRUD tasks (GET ro'yxat — listTasks, GET bitta — showTask) ──

    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'title'       => 'required|string|max:255',
            'description' => 'nullable|string',
            'is_active'   => 'boolean',
            'sort_order'  => 'integer|min:0',
            'task_kind'   => 'sometimes|in:interesting,project',
        ]);
        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $data = $v->validated();
        if (! isset($data['task_kind'])) {
            $data['task_kind'] = InterestingTask::KIND_INTERESTING;
        }

        $task = InterestingTask::create($data);

        return response()->json(['status' => 'success', 'data' => ['task' => $task]], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $task = InterestingTask::findOrFail($id);
        $v = Validator::make($request->all(), [
            'title'       => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'is_active'   => 'boolean',
            'sort_order'  => 'integer|min:0',
            'task_kind'   => 'sometimes|in:interesting,project',
        ]);
        if ($v->fails()) return $this->fail($v->errors(), 422);

        $task->update($v->validated());

        return response()->json(['status' => 'success', 'data' => ['task' => $task]]);
    }

    public function destroy(int $id): JsonResponse
    {
        InterestingTask::findOrFail($id)->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }

    // ── Admin: Questions ───────────────────────────────────────────

    public function storeQuestion(Request $request, int $taskId): JsonResponse
    {
        $task = InterestingTask::findOrFail($taskId);

        $v = Validator::make($request->all(), [
            'question_type'              => 'required|in:text,image,match,word_search,matrix_classification',
            'body'                       => 'required|string',
            'sort_order'                 => 'integer|min:0',
            'image'                      => 'nullable|image|max:5120',
            'match_left'                 => 'nullable|array|min:2',
            'match_left.*'               => 'required|string|max:2000',
            'match_right'                => 'nullable|array|min:2',
            'match_right.*'              => 'required|string|max:2000',
            // word_search
            'word_search_grid'           => 'nullable|array|min:2',
            'word_search_grid.*'         => 'array|min:1',
            'word_search_grid.*.*'       => 'string|max:10',
            'word_search_clues'          => 'nullable|array|min:1',
            'word_search_clues.*.formula'     => 'required|string|max:200',
            'word_search_clues.*.common_name' => 'required|string|max:200',
            'word_search_clues.*.answer'      => 'required|string|max:200',
            // matrix_classification
            'matrix_data'                => 'nullable|array',
            'matrix_data.rows'           => 'nullable|array|min:2',
            'matrix_data.rows.*.id'      => 'required|integer|min:1',
            'matrix_data.rows.*.text'    => 'required|string|max:4000',
            'matrix_data.answer_key'                 => 'nullable|array',
            'matrix_data.answer_key.method'          => 'nullable|array',
            'matrix_data.answer_key.method.*'        => 'in:solve,ammonia,none',
            'matrix_data.answer_key.order'           => 'nullable|array',
            'matrix_data.answer_key.order.*'         => 'integer|min:1|max:200',
            'matrix_data.sequence'                   => 'nullable|array',
            'matrix_data.sequence.enabled'           => 'nullable|boolean',
            'matrix_data.sequence.label'             => 'nullable|string|max:255',
            'matrix_data.sequence.max_step'          => 'nullable|integer|min:1|max:200',
        ]);

        $type = $request->input('question_type');

        if ($type === 'match') {
            $v->after(function ($validator) use ($request) {
                $left  = $request->input('match_left', []);
                $right = $request->input('match_right', []);
                if (count($left) < 2 || count($right) < 2) {
                    $validator->errors()->add('match_data', 'Chap va o\'ng ustunda kamida 2 ta qator bo\'lishi kerak.');
                }
                if (count($left) !== count($right)) {
                    $validator->errors()->add('match_data', 'Chap va o\'ng qatorlar soni teng bo\'lishi kerak.');
                }
            });
        }

        if ($type === TaskQuestion::TYPE_WORD_SEARCH) {
            $v->after(function ($validator) use ($request) {
                $grid   = $request->input('word_search_grid', []);
                $clues  = $request->input('word_search_clues', []);
                if (count($grid) < 2) {
                    $validator->errors()->add('word_search_grid', 'Panjara kamida 2 qatordan iborat bo\'lishi kerak.');
                }
                if (count($clues) < 1) {
                    $validator->errors()->add('word_search_clues', 'Kamida 1 ta maslahat (izoh) kiritilishi kerak.');
                }
            });
        }

        if ($type === TaskQuestion::TYPE_MATRIX_CLASSIFICATION) {
            $v->after(function ($validator) use ($request) {
                $matrixData = $request->input('matrix_data');
                if (!is_array($matrixData)) {
                    $validator->errors()->add('matrix_data', 'Jadval turi uchun matrix_data majburiy.');
                    return;
                }

                $rows = $matrixData['rows'] ?? [];
                if (!is_array($rows) || count($rows) < 2) {
                    $validator->errors()->add('matrix_data.rows', 'Kamida 2 ta qator kiriting.');
                }
            });
        }

        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        if ($type === TaskQuestion::TYPE_IMAGE && !$request->hasFile('image')) {
            return $this->fail(['image' => ['Rasm fayli majburiy']], 422);
        }

        $matchData = null;
        if ($type === TaskQuestion::TYPE_MATCH) {
            $matchData = [
                'left'  => array_values($request->input('match_left', [])),
                'right' => array_values($request->input('match_right', [])),
            ];
        }
        if ($type === TaskQuestion::TYPE_WORD_SEARCH) {
            $clues = array_values($request->input('word_search_clues', []));
            $matchData = [
                'grid'  => $request->input('word_search_grid', []),
                'clues' => array_map(function ($c, $i) {
                    return [
                        'id'          => $i + 1,
                        'formula'     => $c['formula'],
                        'common_name' => $c['common_name'],
                        'answer'      => mb_strtoupper($c['answer']),
                    ];
                }, $clues, array_keys($clues)),
            ];
        }
        if ($type === TaskQuestion::TYPE_MATRIX_CLASSIFICATION) {
            $matchData = $request->input('matrix_data');
        }

        $q = $task->questions()->create([
            'body'           => $request->input('body'),
            'sort_order'     => $request->integer('sort_order', 0),
            'question_type'  => $type,
            'match_data'     => $matchData,
            'image_path'     => null,
        ]);

        if ($type === TaskQuestion::TYPE_IMAGE && $request->hasFile('image')) {
            $path = $request->file('image')->store("task-questions/{$q->id}", 'public');
            $q->update(['image_path' => $path]);
        }

        return response()->json(['status' => 'success', 'data' => ['question' => $q->fresh()]], 201);
    }

    public function updateQuestion(Request $request, int $taskId, int $questionId): JsonResponse
    {
        $q = TaskQuestion::where('task_id', $taskId)->findOrFail($questionId);

        $v = Validator::make($request->all(), [
            'question_type'                   => 'sometimes|in:text,image,match,word_search,matrix_classification',
            'body'                            => 'sometimes|required|string',
            'sort_order'                      => 'sometimes|integer|min:0',
            'image'                           => 'nullable|image|max:5120',
            'match_left'                      => 'nullable|array|min:2',
            'match_left.*'                    => 'required|string|max:2000',
            'match_right'                     => 'nullable|array|min:2',
            'match_right.*'                   => 'required|string|max:2000',
            // word_search
            'word_search_grid'                => 'nullable|array|min:2',
            'word_search_grid.*'              => 'array|min:1',
            'word_search_grid.*.*'            => 'string|max:10',
            'word_search_clues'               => 'nullable|array|min:1',
            'word_search_clues.*.formula'     => 'required|string|max:200',
            'word_search_clues.*.common_name' => 'required|string|max:200',
            'word_search_clues.*.answer'      => 'required|string|max:200',
            // matrix_classification
            'matrix_data'                     => 'nullable|array',
            'matrix_data.rows'                => 'nullable|array|min:2',
            'matrix_data.rows.*.id'           => 'required|integer|min:1',
            'matrix_data.rows.*.text'         => 'required|string|max:4000',
            'matrix_data.answer_key'                 => 'nullable|array',
            'matrix_data.answer_key.method'          => 'nullable|array',
            'matrix_data.answer_key.method.*'        => 'in:solve,ammonia,none',
            'matrix_data.answer_key.order'           => 'nullable|array',
            'matrix_data.answer_key.order.*'         => 'integer|min:1|max:200',
            'matrix_data.sequence'                   => 'nullable|array',
            'matrix_data.sequence.enabled'           => 'nullable|boolean',
            'matrix_data.sequence.label'             => 'nullable|string|max:255',
            'matrix_data.sequence.max_step'          => 'nullable|integer|min:1|max:200',
        ]);

        $type = $request->has('question_type') ? $request->input('question_type') : $q->question_type;

        $v->after(function ($validator) use ($request, $q, $type) {
            if ($type === TaskQuestion::TYPE_MATCH) {
                $hasLeft  = $request->has('match_left');
                $hasRight = $request->has('match_right');
                if ($hasLeft xor $hasRight) {
                    $validator->errors()->add('match_data', 'match_left va match_right birga yuborilishi kerak.');
                    return;
                }
                if ($hasLeft && $hasRight) {
                    $left  = $request->input('match_left', []);
                    $right = $request->input('match_right', []);
                    if (count($left) < 2 || count($right) < 2) {
                        $validator->errors()->add('match_data', 'Chap va o\'ng ustunda kamida 2 ta qator bo\'lishi kerak.');
                    }
                    if (count($left) !== count($right)) {
                        $validator->errors()->add('match_data', 'Chap va o\'ng qatorlar soni teng bo\'lishi kerak.');
                    }
                    return;
                }
                $switchingToMatch = $request->input('question_type') === TaskQuestion::TYPE_MATCH
                    && $q->question_type !== TaskQuestion::TYPE_MATCH;
                if ($switchingToMatch) {
                    $validator->errors()->add('match_data', 'Juftlash ustunlarini yuboring (match_left, match_right).');
                }
            }

            if ($type === TaskQuestion::TYPE_WORD_SEARCH) {
                $hasGrid  = $request->has('word_search_grid');
                $hasClues = $request->has('word_search_clues');
                $switchingToWs = $request->input('question_type') === TaskQuestion::TYPE_WORD_SEARCH
                    && $q->question_type !== TaskQuestion::TYPE_WORD_SEARCH;

                if ($hasGrid) {
                    $grid = $request->input('word_search_grid', []);
                    if (count($grid) < 2) {
                        $validator->errors()->add('word_search_grid', 'Panjara kamida 2 qatordan iborat bo\'lishi kerak.');
                    }
                }
                if ($hasClues) {
                    $clues = $request->input('word_search_clues', []);
                    if (count($clues) < 1) {
                        $validator->errors()->add('word_search_clues', 'Kamida 1 ta maslahat (izoh) kiritilishi kerak.');
                    }
                }
                if ($switchingToWs && !$hasGrid) {
                    $validator->errors()->add('word_search_grid', 'So\'z qidirish panjara (grid) majburiy.');
                }
                if ($switchingToWs && !$hasClues) {
                    $validator->errors()->add('word_search_clues', 'So\'z qidirish izohlarini yuboring.');
                }
            }

            if ($type === TaskQuestion::TYPE_MATRIX_CLASSIFICATION) {
                $hasMatrixData = $request->has('matrix_data');
                $switchingToMatrix = $request->input('question_type') === TaskQuestion::TYPE_MATRIX_CLASSIFICATION
                    && $q->question_type !== TaskQuestion::TYPE_MATRIX_CLASSIFICATION;

                if ($hasMatrixData) {
                    $matrixData = $request->input('matrix_data');
                    $rows = is_array($matrixData) ? ($matrixData['rows'] ?? []) : [];
                    if (!is_array($rows) || count($rows) < 2) {
                        $validator->errors()->add('matrix_data.rows', 'Kamida 2 ta qator kiriting.');
                    }
                }

                if ($switchingToMatrix && !$hasMatrixData) {
                    $validator->errors()->add('matrix_data', 'Jadval savoli uchun matrix_data yuborilishi kerak.');
                }
            }
        });

        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $updates = [];

        if ($request->has('body')) {
            $updates['body'] = $request->input('body');
        }
        if ($request->has('sort_order')) {
            $updates['sort_order'] = $request->integer('sort_order');
        }

        if ($request->has('question_type')) {
            $newType = $request->input('question_type');
            $updates['question_type'] = $newType;

            if ($newType !== TaskQuestion::TYPE_IMAGE && $q->image_path) {
                Storage::disk('public')->delete($q->image_path);
                $updates['image_path'] = null;
            }
            // match_data faqat maxsus turlar (match, word_search, matrix_classification) bo'lmaganda tozalanadi
            if (
                $newType !== TaskQuestion::TYPE_MATCH &&
                $newType !== TaskQuestion::TYPE_WORD_SEARCH &&
                $newType !== TaskQuestion::TYPE_MATRIX_CLASSIFICATION
            ) {
                $updates['match_data'] = null;
            }
        }

        if ($type === TaskQuestion::TYPE_MATCH && $request->has('match_left') && $request->has('match_right')) {
            $updates['match_data'] = [
                'left'  => array_values($request->input('match_left', [])),
                'right' => array_values($request->input('match_right', [])),
            ];
        }

        if ($type === TaskQuestion::TYPE_WORD_SEARCH && $request->has('word_search_grid') && $request->has('word_search_clues')) {
            $clues = array_values($request->input('word_search_clues', []));
            $updates['match_data'] = [
                'grid'  => $request->input('word_search_grid', []),
                'clues' => array_map(function ($c, $i) {
                    return [
                        'id'          => $i + 1,
                        'formula'     => $c['formula'],
                        'common_name' => $c['common_name'],
                        'answer'      => mb_strtoupper($c['answer']),
                    ];
                }, $clues, array_keys($clues)),
            ];
        }

        if ($type === TaskQuestion::TYPE_MATRIX_CLASSIFICATION && $request->has('matrix_data')) {
            $updates['match_data'] = $request->input('matrix_data');
        }

        if (!empty($updates)) {
            $q->update($updates);
            $q->refresh();
        }

        if ($q->question_type === TaskQuestion::TYPE_IMAGE && $request->hasFile('image')) {
            if ($q->image_path) {
                Storage::disk('public')->delete($q->image_path);
            }
            $path = $request->file('image')->store("task-questions/{$q->id}", 'public');
            $q->update(['image_path' => $path]);
        }

        return response()->json(['status' => 'success', 'data' => ['question' => $q->fresh()]]);
    }

    public function destroyQuestion(int $taskId, int $questionId): JsonResponse
    {
        $q = TaskQuestion::where('task_id', $taskId)->findOrFail($questionId);
        if ($q->image_path) {
            Storage::disk('public')->delete($q->image_path);
        }
        $q->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }

    // ── Admin: Submissions ─────────────────────────────────────────

    public function submissions(Request $request): JsonResponse
    {
        $query = TaskSubmission::with(['task:id,title,task_kind', 'user:id,name,email,school_id'])
            ->whereHas('task', function ($q) {
                $q->where('task_kind', InterestingTask::KIND_INTERESTING);
            })
            ->orderByDesc('created_at');

        if ($request->has('task_id')) {
            $query->where('task_id', $request->integer('task_id'));
        }
        if ($request->has('status')) {
            $query->where('status', $request->input('status'));
        }

        // Maktab filtri (user.school_id orqali)
        if ($request->filled('school_id')) {
            $query->whereHas('user', function ($q) use ($request) {
                $q->where('school_id', $request->integer('school_id'));
            });
        }

        // O'quv yili filtri — "YYYY-YYYY" formatida, masalan "2025-2026"
        // O'quv yili: sentyabr 1 → keyingi yil avg 31
        if ($request->filled('academic_year')) {
            $parts = explode('-', $request->input('academic_year'));
            if (count($parts) === 2 && is_numeric($parts[0]) && is_numeric($parts[1])) {
                $startYear = (int) $parts[0];
                $endYear   = (int) $parts[1];
                $from = "{$startYear}-09-01 00:00:00";
                $to   = "{$endYear}-08-31 23:59:59";
                $query->whereBetween('created_at', [$from, $to]);
            }
        }

        return response()->json(['status' => 'success', 'data' => ['submissions' => $query->get()]]);
    }

    public function submissionDetail(int $submissionId): JsonResponse
    {
        $sub = TaskSubmission::with([
            'task:id,title',
            'user:id,name,email',
            'answers.question:id,body,sort_order,question_type,image_path,match_data',
        ])->findOrFail($submissionId);

        $sub->answers->each(function (TaskAnswer $answer): void {
            $answer->setAttribute('auto_check', $this->buildAutoCheck($answer));
        });

        return response()->json(['status' => 'success', 'data' => ['submission' => $sub]]);
    }

    public function checkSubmission(Request $request, int $submissionId): JsonResponse
    {
        $sub = TaskSubmission::with('answers.question')->findOrFail($submissionId);

        $v = Validator::make($request->all(), [
            'teacher_comment' => 'nullable|string',
            'result_visible'  => 'boolean',
            'use_auto_grading'=> 'boolean',
            'answers'         => 'array',
            'answers.*.id'    => 'required|integer|exists:task_answers,id',
            'answers.*.is_correct'      => 'nullable|boolean',
            'answers.*.score'           => 'nullable|integer|min:0|max:100',
            'answers.*.teacher_comment' => 'nullable|string',
        ]);
        if ($v->fails()) return $this->fail($v->errors(), 422);

        $data = $v->validated();

        $useAutoGrading = (bool) ($data['use_auto_grading'] ?? false);
        $answersById = $sub->answers->keyBy('id');

        foreach ($data['answers'] ?? [] as $answerData) {
            /** @var TaskAnswer|null $answerModel */
            $answerModel = $answersById->get((int) $answerData['id']);
            $auto = $useAutoGrading && $answerModel
                ? $this->buildAutoCheck($answerModel)
                : ['supported' => false, 'is_correct' => null, 'score' => null];

            $isCorrect = array_key_exists('is_correct', $answerData)
                ? $answerData['is_correct']
                : (($auto['supported'] ?? false) ? ($auto['is_correct'] ?? null) : null);

            $score = array_key_exists('score', $answerData)
                ? (int) $answerData['score']
                : (($auto['supported'] ?? false) && isset($auto['score']) ? (int) $auto['score'] : 0);

            TaskAnswer::where('id', $answerData['id'])
                ->where('submission_id', $sub->id)
                ->update([
                    'is_correct'      => $isCorrect,
                    'score'           => $score,
                    'teacher_comment' => $answerData['teacher_comment'] ?? null,
                ]);
        }

        $totalScore = $sub->answers()->sum('score');

        $sub->update([
            'status'          => 'checked',
            'teacher_comment' => $data['teacher_comment'] ?? $sub->teacher_comment,
            'result_visible'  => $data['result_visible'] ?? $sub->result_visible,
            'total_score'     => $totalScore,
            'checked_at'      => now(),
        ]);

        return response()->json(['status' => 'success', 'data' => ['submission' => $sub->fresh(['answers.question'])]]);
    }

    /** PATCH: { result_visible?: bool } — berilsa aniq o'rnatadi; yo'q bo'lsa toggle (faqat tekshirilgan) */
    public function updateSubmissionVisibility(Request $request, int $submissionId): JsonResponse
    {
        $sub = TaskSubmission::findOrFail($submissionId);

        if ($sub->status !== 'checked') {
            return $this->fail(['submission' => ['Tekshirilguncha natija ko\'rinmasligi sozlanmaydi.']], 422);
        }

        if ($request->has('result_visible')) {
            $v = Validator::make($request->all(), ['result_visible' => 'required|boolean']);
            if ($v->fails()) {
                return $this->fail($v->errors(), 422);
            }
            $sub->update(['result_visible' => $v->validated()['result_visible']]);
        } else {
            $sub->update(['result_visible' => ! $sub->result_visible]);
        }

        $sub->refresh();

        return response()->json(['status' => 'success', 'data' => ['result_visible' => (bool) $sub->result_visible]]);
    }

    /** Bitta topshiriqni o'chirish */
    public function destroySubmission(int $submissionId): JsonResponse
    {
        $sub = TaskSubmission::findOrFail($submissionId);
        $sub->answers()->delete();
        $sub->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }

    /** Bitta topshiriqni qayta ishlashga qaytarish (pending) */
    public function resetSubmission(int $submissionId): JsonResponse
    {
        $sub = TaskSubmission::findOrFail($submissionId);

        $sub->update([
            'status'          => 'pending',
            'total_score'     => 0,
            'teacher_comment' => null,
            'result_visible'  => false,
            'checked_at'      => null,
        ]);

        $sub->answers()->update([
            'is_correct'      => null,
            'score'           => 0,
            'teacher_comment' => null,
        ]);

        return response()->json(['status' => 'success', 'data' => ['submission' => $sub->fresh()]]);
    }

    /** Ommaviy o'chirish */
    public function bulkDestroySubmissions(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'submission_ids'   => 'required|array|min:1',
            'submission_ids.*' => 'integer|exists:task_submissions,id',
        ]);
        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $ids = $v->validated()['submission_ids'];
        TaskAnswer::whereIn('submission_id', $ids)->delete();
        $deleted = TaskSubmission::whereIn('id', $ids)->delete();

        return response()->json(['status' => 'success', 'data' => ['deleted' => $deleted]]);
    }

    /** Ommaviy qayta ishlashga qaytarish */
    public function bulkResetSubmissions(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'submission_ids'   => 'required|array|min:1',
            'submission_ids.*' => 'integer|exists:task_submissions,id',
        ]);
        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $ids = $v->validated()['submission_ids'];

        TaskSubmission::whereIn('id', $ids)->update([
            'status'          => 'pending',
            'total_score'     => 0,
            'teacher_comment' => null,
            'result_visible'  => false,
            'checked_at'      => null,
        ]);

        TaskAnswer::whereIn('submission_id', $ids)->update([
            'is_correct'      => null,
            'score'           => 0,
            'teacher_comment' => null,
        ]);

        return response()->json(['status' => 'success', 'data' => ['reset' => count($ids)]]);
    }

    /** Tanlangan tekshirilgan topshiriqlar uchun bir xil ko'rinuvchanlik */
    public function bulkUpdateSubmissionVisibility(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'submission_ids'   => 'required|array|min:1',
            'submission_ids.*' => 'integer|exists:task_submissions,id',
            'result_visible'   => 'required|boolean',
        ]);
        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $ids = $v->validated()['submission_ids'];
        $visible = $v->validated()['result_visible'];

        $updated = TaskSubmission::whereIn('id', $ids)
            ->where('status', 'checked')
            ->update(['result_visible' => $visible]);

        return response()->json(['status' => 'success', 'data' => ['updated' => $updated]]);
    }

    /**
     * public/storage CORS sarlavhasiz chiqishi mumkin (ayniqsa `php artisan serve`).
     * Flutter web Image.network fetch/XHR bilan yuklaydi — shu marshrut orqali fayl beriladi.
     */
    public function publicStorageFile(string $path): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        $relative = str_replace('\\', '/', $path);
        if (str_contains($relative, '..')) {
            abort(404);
        }
        $relative = ltrim($relative, '/');
        if ($relative === '') {
            abort(404);
        }

        $diskRoot = realpath(Storage::disk('public')->path(''));
        if ($diskRoot === false) {
            abort(500);
        }
        $candidate = Storage::disk('public')->path($relative);
        $real = realpath($candidate);
        $rootNorm = strtolower(str_replace('\\', '/', $diskRoot));
        $realNorm = $real !== false ? strtolower(str_replace('\\', '/', $real)) : '';
        if ($real === false || ! str_starts_with($realNorm, $rootNorm)) {
            abort(404);
        }

        if (! is_file($real)) {
            abort(404);
        }

        $mime = @mime_content_type($real) ?: 'application/octet-stream';

        return response()->file($real, [
            'Content-Type' => $mime,
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    // ── Ro'yxat va bitta mavzu (mobil + admin bir URL) ─────────────

    public function listTasks(Request $request): JsonResponse
    {
        $query = InterestingTask::withCount('questions', 'submissions')
            ->orderBy('sort_order')
            ->orderBy('id');

        $user = $request->user();
        $isAdmin = $user && ($user->role ?? null) === 'admin';

        if (! $isAdmin) {
            $query->where('is_active', true);
        }

        $kind = $request->query('kind');
        if ($kind === InterestingTask::KIND_INTERESTING || $kind === InterestingTask::KIND_PROJECT) {
            $query->where('task_kind', $kind);
        } elseif (! $isAdmin) {
            // Eski mobil versiyalar parametrsiz chaqirsa — faqat qiziqarli topshiriqlar
            $query->where('task_kind', InterestingTask::KIND_INTERESTING);
        } else {
            // Admin parametrsiz chaqirsa — faqat qiziqarli (loyihalar alohida sahifada)
            $query->where('task_kind', InterestingTask::KIND_INTERESTING);
        }

        $tasks = $query->get();

        if ($user && !$isAdmin) {
            $taskIds = $tasks->pluck('id');
            if ($taskIds->isNotEmpty()) {
                $subs = TaskSubmission::where('user_id', $user->id)
                    ->whereIn('task_id', $taskIds)
                    ->orderByDesc('created_at')
                    ->get()
                    ->unique('task_id')
                    ->keyBy('task_id');

                foreach ($tasks as $task) {
                    $sub = $subs->get($task->id);
                    $task->setAttribute('my_submission', $sub ? [
                        'id'             => $sub->id,
                        'status'         => $sub->status,
                        'result_visible' => (bool) $sub->result_visible,
                        'total_score'    => (int) $sub->total_score,
                    ] : null);
                }
            }
        }

        $payload = $tasks->map(function (InterestingTask $task) {
            $row = [
                'id'                => $task->id,
                'title'             => $task->title,
                'description'       => $task->description,
                'is_active'         => (bool) $task->is_active,
                'sort_order'        => (int) $task->sort_order,
                'task_kind'         => $task->task_kind,
                'questions_count'   => (int) ($task->questions_count ?? 0),
                'submissions_count' => (int) ($task->submissions_count ?? 0),
            ];
            if ($task->getAttribute('my_submission') !== null) {
                $row['my_submission'] = $task->getAttribute('my_submission');
            }

            return $row;
        })->values();

        return response()->json(['status' => 'success', 'data' => ['tasks' => $payload]]);
    }

    public function showTask(Request $request, int $id): JsonResponse
    {
        $query = InterestingTask::with('questions');

        $user = $request->user();
        $isAdmin = $user && ($user->role ?? null) === 'admin';

        if (!$isAdmin) {
            $query->where('is_active', true);
        }

        $task = $query->findOrFail($id);

        $kind = $request->query('kind');
        if (! $isAdmin && ($kind === InterestingTask::KIND_INTERESTING || $kind === InterestingTask::KIND_PROJECT)) {
            if ($task->task_kind !== $kind) {
                abort(404);
            }
        }

        return response()->json(['status' => 'success', 'data' => ['task' => $task]]);
    }

    public function submit(Request $request, int $id): JsonResponse
    {
        $task = InterestingTask::where('is_active', true)->with('questions')->findOrFail($id);

        if ($task->task_kind === InterestingTask::KIND_PROJECT) {
            return $this->fail(['task' => ['Loyihalar uchun javob yuborish mumkin emas.']], 422);
        }

        $user = $request->user();

        $v = Validator::make($request->all(), [
            'answers'        => 'required|array',
            'answers.*.question_id' => [
                'required',
                'integer',
                Rule::exists('task_questions', 'id')->where('task_id', $task->id),
            ],
            'answers.*.answer_text' => 'required|string',
        ]);
        $v->after(function ($validator) use ($request, $task) {
            $expected = $task->questions->count();
            $answers = $request->input('answers', []);
            if ($expected !== count($answers)) {
                $validator->errors()->add(
                    'answers',
                    "Javoblar soni savollar soniga teng bo'lishi kerak ($expected ta)."
                );
            }
            $ids = array_column($answers, 'question_id');
            if (count($ids) !== count(array_unique($ids))) {
                $validator->errors()->add('answers', 'Takroriy question_id yuborilgan.');
            }
        });
        if ($v->fails()) {
            return $this->fail($v->errors(), 422);
        }

        $data = $v->validated();

        $submission = TaskSubmission::create([
            'task_id'       => $task->id,
            'user_id'       => $user->id,
            'student_name'  => $user->name,
            'student_email' => $user->email,
            'status'        => 'pending',
            'result_visible'=> false,
        ]);

        foreach ($data['answers'] as $ans) {
            TaskAnswer::create([
                'submission_id' => $submission->id,
                'question_id'   => $ans['question_id'],
                'answer_text'   => $ans['answer_text'],
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data'   => ['submission_id' => $submission->id],
        ], 201);
    }

    public function mySubmissions(Request $request): JsonResponse
    {
        $user = $request->user();
        $submissions = TaskSubmission::where('user_id', $user->id)
            ->whereHas('task', function ($q) {
                $q->where('task_kind', InterestingTask::KIND_INTERESTING);
            })
            ->with('task:id,title,task_kind')
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['status' => 'success', 'data' => ['submissions' => $submissions]]);
    }

    public function mySubmissionDetail(Request $request, int $submissionId): JsonResponse
    {
        $user = $request->user();
        $sub = TaskSubmission::where('user_id', $user->id)
            ->with(['task:id,title', 'answers.question:id,body,sort_order,question_type,image_path,match_data'])
            ->findOrFail($submissionId);

        if (!$sub->result_visible) {
            return response()->json([
                'status' => 'success',
                'data'   => [
                    'submission' => [
                        'id'             => $sub->id,
                        'task'           => $sub->task,
                        'student_name'   => $sub->student_name,
                        'status'         => $sub->status,
                        'result_visible' => false,
                        'created_at'     => $sub->created_at,
                    ],
                ],
            ]);
        }

        return response()->json(['status' => 'success', 'data' => ['submission' => $sub]]);
    }

    /**
     * Auto-check tavsiyasi (preview): tekshiruvchi uchun boshlang'ich ball va correctness.
     *
     * @return array{
     *   supported: bool,
     *   is_correct: bool|null,
     *   score: int|null,
     *   reason: string
     * }
     */
    private function buildAutoCheck(TaskAnswer $answer): array
    {
        $question = $answer->question;
        if (!$question) {
            return [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Question topilmadi.',
            ];
        }

        $matchData = is_array($question->match_data) ? $question->match_data : [];

        return match ($question->question_type) {
            TaskQuestion::TYPE_MATCH => $this->autoCheckMatch($answer->answer_text, $matchData),
            TaskQuestion::TYPE_WORD_SEARCH => $this->autoCheckWordSearch($answer->answer_text, $matchData),
            TaskQuestion::TYPE_MATRIX_CLASSIFICATION => $this->autoCheckMatrix($answer->answer_text, $matchData),
            TaskQuestion::TYPE_TEXT, TaskQuestion::TYPE_IMAGE => $this->autoCheckByAcceptedAnswers($answer->answer_text, $matchData),
            default => [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Bu savol turi uchun auto-check yoqilmagan.',
            ],
        };
    }

    private function autoCheckMatch(string $answerText, array $matchData): array
    {
        $left = is_array($matchData['left'] ?? null) ? $matchData['left'] : [];
        $right = is_array($matchData['right'] ?? null) ? $matchData['right'] : [];
        $expectedTotal = min(count($left), count($right));

        if ($expectedTotal < 1) {
            return [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Juftlash answer key mavjud emas.',
            ];
        }

        $decoded = $this->decodeJsonArray($answerText);
        $pairs = is_array($decoded['pairs'] ?? null) ? $decoded['pairs'] : [];

        $submittedMap = [];
        foreach ($pairs as $pair) {
            if (!is_array($pair) || count($pair) < 2) {
                continue;
            }
            $li = is_numeric($pair[0] ?? null) ? (int) $pair[0] : null;
            $ri = is_numeric($pair[1] ?? null) ? (int) $pair[1] : null;
            if ($li === null || $ri === null) {
                continue;
            }
            if ($li < 0 || $ri < 0 || $li >= $expectedTotal || $ri >= $expectedTotal) {
                continue;
            }
            $submittedMap[$li] = $ri;
        }

        $correct = 0;
        foreach ($submittedMap as $li => $ri) {
            if ($li === $ri) {
                $correct++;
            }
        }

        $score = (int) round(($correct / $expectedTotal) * 100);
        $full = $correct === $expectedTotal && count($submittedMap) === $expectedTotal;

        return [
            'supported' => true,
            'is_correct' => $full,
            'score' => $score,
            'reason' => "To'g'ri juftlar: {$correct}/{$expectedTotal}",
        ];
    }

    private function autoCheckWordSearch(string $answerText, array $matchData): array
    {
        $clues = is_array($matchData['clues'] ?? null) ? $matchData['clues'] : [];
        $expectedIds = [];
        foreach ($clues as $clue) {
            $id = is_array($clue) && is_numeric($clue['id'] ?? null) ? (int) $clue['id'] : 0;
            if ($id > 0) {
                $expectedIds[$id] = true;
            }
        }
        $expected = array_keys($expectedIds);

        if (count($expected) < 1) {
            return [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Word search answer key mavjud emas.',
            ];
        }

        $decoded = $this->decodeJsonArray($answerText);
        $foundRaw = is_array($decoded['found_ids'] ?? null) ? $decoded['found_ids'] : [];
        $foundIds = [];
        foreach ($foundRaw as $id) {
            if (is_numeric($id)) {
                $num = (int) $id;
                if ($num > 0) {
                    $foundIds[$num] = true;
                }
            }
        }

        $found = array_keys($foundIds);
        $correctFound = array_intersect($expected, $found);
        $correctCount = count($correctFound);
        $expectedTotal = count($expected);
        $score = (int) round(($correctCount / $expectedTotal) * 100);
        $full = $correctCount === $expectedTotal && count($found) === $expectedTotal;

        return [
            'supported' => true,
            'is_correct' => $full,
            'score' => $score,
            'reason' => "Topilganlari: {$correctCount}/{$expectedTotal}",
        ];
    }

    private function autoCheckMatrix(string $answerText, array $matchData): array
    {
        $answerKey = is_array($matchData['answer_key'] ?? null) ? $matchData['answer_key'] : [];
        $methodExpected = is_array($answerKey['method'] ?? null) ? $answerKey['method'] : [];
        $orderExpected = is_array($answerKey['order'] ?? null) ? $answerKey['order'] : [];

        $decoded = $this->decodeJsonArray($answerText);
        $methodGiven = is_array($decoded['method'] ?? null) ? $decoded['method'] : [];
        $orderGiven = is_array($decoded['order'] ?? null) ? $decoded['order'] : [];

        $totalChecks = 0;
        $correct = 0;

        foreach ($methodExpected as $rowId => $expectedMethod) {
            $exp = is_string($expectedMethod) ? trim($expectedMethod) : '';
            if (!in_array($exp, ['solve', 'ammonia', 'none'], true)) {
                continue;
            }
            $totalChecks++;
            $given = isset($methodGiven[$rowId]) ? (string) $methodGiven[$rowId] : null;
            if ($given === $exp) {
                $correct++;
            }
        }

        foreach ($orderExpected as $rowId => $expectedOrder) {
            if (!is_numeric($expectedOrder)) {
                continue;
            }
            $totalChecks++;
            $exp = (int) $expectedOrder;
            $given = isset($orderGiven[$rowId]) && is_numeric($orderGiven[$rowId])
                ? (int) $orderGiven[$rowId]
                : null;
            if ($given !== null && $given === $exp) {
                $correct++;
            }
        }

        if ($totalChecks < 1) {
            return [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Matrix answer key topilmadi.',
            ];
        }

        $score = (int) round(($correct / $totalChecks) * 100);

        return [
            'supported' => true,
            'is_correct' => $correct === $totalChecks,
            'score' => $score,
            'reason' => "To'g'ri bandlar: {$correct}/{$totalChecks}",
        ];
    }

    private function autoCheckByAcceptedAnswers(string $answerText, array $matchData): array
    {
        $candidates = [];
        if (is_string($matchData['answer'] ?? null) && trim($matchData['answer']) !== '') {
            $candidates[] = (string) $matchData['answer'];
        }
        if (is_array($matchData['accepted_answers'] ?? null)) {
            foreach ($matchData['accepted_answers'] as $item) {
                if (is_string($item) && trim($item) !== '') {
                    $candidates[] = $item;
                }
            }
        }
        if (is_array($matchData['answers'] ?? null)) {
            foreach ($matchData['answers'] as $item) {
                if (is_string($item) && trim($item) !== '') {
                    $candidates[] = $item;
                }
            }
        }

        $normalizedExpected = [];
        foreach ($candidates as $candidate) {
            $normalizedExpected[$this->normalizeAnswer((string) $candidate)] = true;
        }

        if (count($normalizedExpected) < 1) {
            return [
                'supported' => false,
                'is_correct' => null,
                'score' => null,
                'reason' => 'Bu savolda oldindan answer key berilmagan.',
            ];
        }

        $actual = $this->normalizeAnswer($answerText);
        $ok = $actual !== '' && isset($normalizedExpected[$actual]);

        return [
            'supported' => true,
            'is_correct' => $ok,
            'score' => $ok ? 100 : 0,
            'reason' => $ok ? 'Javob answer key bilan mos.' : 'Javob answer key bilan mos emas.',
        ];
    }

    private function decodeJsonArray(string $raw): array
    {
        $decoded = json_decode($raw, true);
        return is_array($decoded) ? $decoded : [];
    }

    private function normalizeAnswer(string $value): string
    {
        $collapsed = preg_replace('/\s+/u', ' ', trim($value)) ?? '';
        return mb_strtoupper($collapsed);
    }

    private function fail($errors, int $status = 400): JsonResponse
    {
        return response()->json(['status' => 'fail', 'data' => $errors], $status);
    }
}

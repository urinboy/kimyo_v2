<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Quiz;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

/**
 * Darsga bog'lanmagan (lesson_id = null) testlar: Kimyo / Geografiya turlari.
 * Mobil: GET ro'yxat va faol test bo'lsa savollar; Admin: CRUD.
 */
class StandaloneQuizController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Quiz::query()
            ->whereNull('lesson_id')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->withCount('questions');

        if (! $request->user('sanctum')) {
            $query->where('is_active', true);
        }

        if ($request->query('type')) {
            $query->where('type', $request->query('type'));
        }

        $quizzes = $query->get();

        return response()->json([
            'status' => 'success',
            'data' => ['quizzes' => $quizzes],
        ]);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        $quiz = Quiz::query()
            ->whereNull('lesson_id')
            ->with(['questions.translations', 'questions.options.translations'])
            ->find($id);

        if (! $quiz) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }

        if (! $request->user('sanctum') && ! $quiz->is_active) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $quiz],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'type' => 'required|in:chemistry,geography',
            'category' => 'required|string|max:120',
            'title_uz' => 'required|string|max:255',
            'title_ru' => 'nullable|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $data = $v->validated();
        $data['lesson_id'] = null;
        $data['is_active'] = $data['is_active'] ?? true;
        $data['sort_order'] = $data['sort_order'] ?? 0;

        $quiz = Quiz::query()->create($data);
        $quiz->loadCount('questions');

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $quiz],
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $quiz = Quiz::query()->whereNull('lesson_id')->find($id);
        if (! $quiz) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }

        $v = Validator::make($request->all(), [
            'type' => 'sometimes|in:chemistry,geography',
            'category' => 'sometimes|string|max:120',
            'title_uz' => 'sometimes|string|max:255',
            'title_ru' => 'nullable|string|max:255',
            'title_en' => 'nullable|string|max:255',
            'sort_order' => 'nullable|integer|min:0',
            'is_active' => 'boolean',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $quiz->update($v->validated());
        $quiz->loadCount('questions');

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $quiz->fresh()],
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $quiz = Quiz::query()->whereNull('lesson_id')->find($id);
        if (! $quiz) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }
        $quiz->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }
}

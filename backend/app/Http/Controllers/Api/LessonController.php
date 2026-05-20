<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lesson;
use App\Repositories\Interfaces\LessonRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LessonController extends Controller
{
    private LessonRepositoryInterface $repository;

    public function __construct(LessonRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index(Request $request): JsonResponse
    {
        // summary=1: translations.content yo‘q — kichik javob (mobil ilova, bufferniy limitlar)
        $lessons = $request->boolean('summary')
            ? $this->repository->getAllSummary()
            : $this->repository->getAll();
        return response()->json(
            [
                'status' => 'success',
                'data' => ['lessons' => $lessons],
            ],
            200,
            [],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:theory,lab',
            'order' => 'integer',
            'is_active' => 'boolean',
            'translations' => 'required|array|min:1',
            'translations.*.language_id' => 'sometimes|integer|exists:languages,id',
            'translations.*.title' => 'required|string|max:255',
            'translations.*.content' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $lesson = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => ['lesson' => $lesson]
        ], 201);
    }

    public function show(Lesson $lesson): JsonResponse
    {
        $lesson->loadCount([
            'labItems as lab_items_count' => fn ($q) => $q->where('is_active', true),
        ]);
        $lesson->load('translations.language');

        return response()->json(
            [
                'status' => 'success',
                'data' => ['lesson' => $lesson],
            ],
            200,
            [],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
    }

    public function update(Request $request, Lesson $lesson): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'type' => 'in:theory,lab',
            'order' => 'integer',
            'is_active' => 'boolean',
            'translations' => 'array',
            'translations.*.language_id' => 'sometimes|integer|exists:languages,id',
            'translations.*.title' => 'nullable|string|max:255',
            'translations.*.content' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $updated = $this->repository->update($lesson->id, $request->all());

        if ($updated === null) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Lesson not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['lesson' => $updated]
        ]);
    }

    public function destroy(Lesson $lesson): JsonResponse
    {
        $deleted = $this->repository->delete($lesson->id);

        if (! $deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Lesson not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null,
        ]);
    }
}

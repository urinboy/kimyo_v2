<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\QuizRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class QuizController extends Controller
{
    private QuizRepositoryInterface $repository;

    public function __construct(QuizRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function showByLesson(int $lessonId): JsonResponse
    {
        $quiz = $this->repository->findByLessonId($lessonId);

        if (!$quiz) {
            return response()->json([
                'status' => 'fail',
                'data' => ['message' => 'Quiz not found for this lesson']
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $quiz]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'lesson_id' => 'required|exists:lessons,id',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $quiz = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $quiz]
        ], 201);
    }

    public function syncQuestions(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'questions' => 'required|array',
            'questions.*.points' => 'integer',
            'questions.*.order' => 'integer',
            'questions.*.translations' => 'required|array',
            'questions.*.translations.*.text' => 'required|string',
            'questions.*.options' => 'required|array|min:2',
            'questions.*.options.*.is_correct' => 'boolean',
            'questions.*.options.*.translations' => 'required|array',
            'questions.*.options.*.translations.*.text' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        try {
            $quiz = $this->repository->syncQuestions($id, $request->questions);
            return response()->json([
                'status' => 'success',
                'data' => ['quiz' => $quiz]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $updated = $this->repository->update($id, $request->all());

        if (!$updated) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Quiz not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['quiz' => $this->repository->find($id)]
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Quiz not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

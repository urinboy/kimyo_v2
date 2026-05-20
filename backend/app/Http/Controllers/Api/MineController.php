<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\MineRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class MineController extends Controller
{
    private MineRepositoryInterface $repository;

    public function __construct(MineRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index(): JsonResponse
    {
        $mines = $this->repository->getAll();
        return response()->json([
            'status' => 'success',
            'data' => ['mines' => $mines]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'is_active' => 'boolean',
            'translations' => 'required|array',
            'translations.*.name' => 'required|string|max:255',
            'translations.*.description' => 'nullable|string',
            'elements' => 'array',
            'elements.*' => 'exists:elements,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $mine = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => ['mine' => $mine]
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $mine = $this->repository->findById($id);

        if (!$mine) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Mine not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['mine' => $mine]
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'latitude' => 'numeric',
            'longitude' => 'numeric',
            'is_active' => 'boolean',
            'translations' => 'array',
            'translations.*.name' => 'string|max:255',
            'translations.*.description' => 'nullable|string',
            'elements' => 'array',
            'elements.*' => 'exists:elements,id'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $mine = $this->repository->update($id, $request->all());

        if (!$mine) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Mine not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['mine' => $mine]
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Mine not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

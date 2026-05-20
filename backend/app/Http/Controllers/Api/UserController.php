<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\UserRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class UserController extends Controller
{
    private UserRepositoryInterface $repository;

    public function __construct(UserRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index(): JsonResponse
    {
        $users = $this->repository->getAll();
        return response()->json([
            'status' => 'success',
            'data' => ['users' => $users]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'username' => 'nullable|string|max:64|unique:users|alpha_dash',
            'email' => 'nullable|string|email|max:255|unique:users',
            'password' => 'required|string|min:8',
            'role' => 'nullable|string|exists:roles,name',
            'school_id' => 'nullable|integer|exists:schools,id',
            'phone' => 'nullable|string|max:32|unique:users,phone',
            'school_name' => 'nullable|string|max:255',
            'grade' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $user = $this->repository->create($this->normalizeNullableUserFields($validator->validated()));

        return response()->json([
            'status' => 'success',
            'data' => ['user' => $user->load(['roles', 'school'])]
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $user = $this->repository->findById($id);

        if (!$user) {
            return response()->json([
                'status' => 'fail',
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['user' => $user]
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'username' => 'nullable|string|max:64|unique:users,username,'.$id.'|alpha_dash',
            'email' => 'nullable|string|email|max:255|unique:users,email,'.$id,
            'password' => 'nullable|string|min:8',
            'role' => 'nullable|string|exists:roles,name',
            'school_id' => 'nullable|integer|exists:schools,id',
            'phone' => 'nullable|string|max:32|unique:users,phone,'.$id,
            'school_name' => 'nullable|string|max:255',
            'grade' => 'nullable|string|max:50',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $user = $this->repository->update($id, $this->normalizeNullableUserFields($validator->validated()));

        if (!$user) {
            return response()->json([
                'status' => 'fail',
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['user' => $user->load(['roles', 'school'])]
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function normalizeNullableUserFields(array $data): array
    {
        foreach (['username', 'email', 'phone', 'school_name', 'grade'] as $field) {
            if (array_key_exists($field, $data) && $data[$field] === '') {
                $data[$field] = null;
            }
        }

        return $data;
    }
}

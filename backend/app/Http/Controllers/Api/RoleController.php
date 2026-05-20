<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\RoleRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class RoleController extends Controller
{
    private RoleRepositoryInterface $repository;

    public function __construct(RoleRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index(): JsonResponse
    {
        $roles = $this->repository->getAll();
        $permissions = $this->repository->getAllPermissions();
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'roles' => $roles,
                'permissions' => $permissions
            ]
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|unique:roles,name',
            'permissions' => 'array',
            'permissions.*' => 'string|exists:permissions,name'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $role = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => ['role' => $role->load('permissions')]
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|unique:roles,name,'.$id,
            'permissions' => 'array',
            'permissions.*' => 'string|exists:permissions,name'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $role = $this->repository->update($id, $request->all());

        if (!$role) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Role not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['role' => $role->load('permissions')]
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        if ($id === 1) { // Protecting Super Admin
            return response()->json([
                'status' => 'fail',
                'message' => 'Cannot delete primary admin role'
            ], 403);
        }

        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Role not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

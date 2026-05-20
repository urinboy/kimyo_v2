<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\PermissionRegistrar;

class PermissionController extends Controller
{
    public function index(): JsonResponse
    {
        $permissions = Permission::query()
            ->where('guard_name', 'web')
            ->withCount('roles')
            ->orderBy('name')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'permissions' => $permissions,
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => [
                'required',
                'string',
                'max:255',
                'regex:/^[a-z][a-z0-9_]*$/',
                Rule::unique('permissions', 'name')->where('guard_name', 'web'),
            ],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors(),
            ], 422);
        }

        $permission = Permission::create([
            'name' => $request->input('name'),
            'guard_name' => 'web',
        ]);

        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        return response()->json([
            'status' => 'success',
            'data' => ['permission' => $permission],
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        /** @var Permission|null $permission */
        $permission = Permission::query()->where('guard_name', 'web')->find($id);

        if ($permission === null) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Permission not found',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'name' => [
                'required',
                'string',
                'max:255',
                'regex:/^[a-z][a-z0-9_]*$/',
                Rule::unique('permissions', 'name')
                    ->where('guard_name', 'web')
                    ->ignore($permission->id),
            ],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors(),
            ], 422);
        }

        $permission->update(['name' => $request->input('name')]);

        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        return response()->json([
            'status' => 'success',
            'data' => ['permission' => $permission->fresh()],
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        /** @var Permission|null $permission */
        $permission = Permission::query()->where('guard_name', 'web')->find($id);

        if ($permission === null) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Permission not found',
            ], 404);
        }

        $permission->delete();

        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        return response()->json([
            'status' => 'success',
            'data' => null,
        ], 204);
    }
}

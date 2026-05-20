<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Repositories\Interfaces\SchoolRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class SchoolController extends Controller
{
    public function __construct(
        private SchoolRepositoryInterface $repository
    ) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'data' => ['schools' => $this->repository->all()],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'short_name' => 'nullable|string|max:120',
            'region' => 'nullable|string|max:120',
            'city' => 'nullable|string|max:120',
            'address' => 'nullable|string|max:500',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors(),
            ], 422);
        }

        $school = $this->repository->create($validator->validated());

        return response()->json([
            'status' => 'success',
            'data' => ['school' => $school->loadCount('users')],
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $school = $this->repository->find($id);
        if (! $school) {
            return response()->json([
                'status' => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['school' => $school],
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'short_name' => 'nullable|string|max:120',
            'region' => 'nullable|string|max:120',
            'city' => 'nullable|string|max:120',
            'address' => 'nullable|string|max:500',
            'is_active' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors(),
            ], 422);
        }

        $school = $this->repository->update($id, $validator->validated());
        if (! $school) {
            return response()->json([
                'status' => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['school' => $school],
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $ok = $this->repository->delete($id);
        if (! $ok) {
            return response()->json([
                'status' => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null,
        ], 204);
    }

    /**
     * Return students and performance stats for a given school.
     * Used by the Admin panel "View School" page.
     */
    public function students(int $id): JsonResponse
    {
        $school = $this->repository->find($id);
        if (! $school) {
            return response()->json([
                'status'  => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        // Load full school with users count
        $school->loadCount('users');

        // Students list with task-submission counts and avg score
        $students = User::where('school_id', $id)
            ->select('id', 'name', 'phone', 'grade', 'school_id', 'created_at')
            ->withCount('taskSubmissions as total_submissions')
            ->withAvg('taskSubmissions as avg_score', 'total_score')
            ->orderBy('name')
            ->get()
            ->map(function ($u) {
                $u->avg_score = round($u->avg_score ?? 0, 1);
                return $u;
            });

        // Aggregate performance stats
        $stats = [
            'total_students'       => $students->count(),
            'active_students'      => $students->where('total_submissions', '>', 0)->count(),
            'avg_score'            => round($students->avg('avg_score') ?? 0, 1),
            'top_score'            => $students->max('avg_score') ?? 0,
        ];

        return response()->json([
            'status' => 'success',
            'data'   => [
                'school'   => $school,
                'students' => $students,
                'stats'    => $stats,
            ],
        ]);
    }

    /**
     * Maktabga biriktirish mumkin bo‘lgan foydalanuvchilar: faqat role=user va school_id=null.
     */
    public function assignableUsers(int $id): JsonResponse
    {
        if (! $this->repository->find($id)) {
            return response()->json([
                'status'  => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        $users = User::query()
            ->where('role', 'user')
            ->whereNull('school_id')
            ->orderBy('name')
            ->get(['id', 'name', 'phone', 'email', 'username', 'grade']);

        return response()->json([
            'status' => 'success',
            'data'   => ['users' => $users],
        ]);
    }

    /**
     * Tanlangan foydalanuvchilarni ushbu maktabga biriktirish (boshqa maktabda bo‘lganlar rad etiladi).
     */
    public function attachStudents(Request $request, int $id): JsonResponse
    {
        $school = $this->repository->find($id);
        if (! $school) {
            return response()->json([
                'status'  => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'user_ids'   => 'required|array|min:1',
            'user_ids.*' => 'integer|distinct|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $ids = collect($validator->validated()['user_ids'])->unique()->values()->all();

        $blocked = User::query()
            ->whereIn('id', $ids)
            ->where(function ($q) {
                $q->where('role', '!=', 'user')
                    ->orWhereNotNull('school_id');
            })
            ->pluck('id');

        if ($blocked->isNotEmpty()) {
            return response()->json([
                'status'  => 'fail',
                'message' => 'Bazi foydalanuvchilarni biriktirib bo‘lmaydi (admin yoki boshqa maktabga bog‘langan).',
                'data'    => ['blocked_user_ids' => $blocked->values()->all()],
            ], 422);
        }

        User::whereIn('id', $ids)->update(['school_id' => $id]);

        return response()->json([
            'status' => 'success',
            'data'   => ['attached' => count($ids)],
        ]);
    }

    /**
     * Tanlangan o‘quvchilarni maktabdan ajratish (faqat joriy maktabdagi yozuvlar).
     */
    public function detachStudents(Request $request, int $id): JsonResponse
    {
        if (! $this->repository->find($id)) {
            return response()->json([
                'status'  => 'fail',
                'message' => 'School not found',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'user_ids'   => 'required|array|min:1',
            'user_ids.*' => 'integer|distinct|exists:users,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $ids = collect($validator->validated()['user_ids'])->unique()->values()->all();

        $detached = User::query()
            ->whereIn('id', $ids)
            ->where('school_id', $id)
            ->update(['school_id' => null]);

        return response()->json([
            'status' => 'success',
            'data'   => ['detached' => $detached],
        ]);
    }
}

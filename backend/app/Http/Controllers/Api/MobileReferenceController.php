<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GradeLevel;
use App\Models\School;
use App\Repositories\Interfaces\SchoolRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Mobile Reference', description: "Mobil ilova — maktab va sinf ro'yxatlari")]
class MobileReferenceController extends Controller
{
    public function __construct(
        private SchoolRepositoryInterface $schoolRepository
    ) {}

    #[OA\Get(
        path: '/api/v1/mobile/reference/schools',
        summary: 'Faol maktablar ro‘yxati',
        tags: ['Mobile Reference']
    )]
    #[OA\Response(response: 200, description: 'JSend success')]
    public function schools(): JsonResponse
    {
        $schools = School::query()
            ->where('is_active', true)
            ->orderBy('name')
            ->get(['id', 'name', 'short_name', 'city', 'region']);

        return response()->json([
            'status' => 'success',
            'data'   => ['schools' => $schools],
        ]);
    }

    #[OA\Get(
        path: '/api/v1/mobile/reference/grades',
        summary: 'Sinf (grade) qiymatlari',
        tags: ['Mobile Reference']
    )]
    #[OA\Response(response: 200, description: 'JSend success')]
    public function grades(): JsonResponse
    {
        $grades = GradeLevel::query()
            ->whereIn('label', GradeLevel::ALLOWED_LABELS)
            ->orderBy('sort_order')
            ->orderBy('label')
            ->get(['id', 'label', 'sort_order']);

        return response()->json([
            'status' => 'success',
            'data'   => ['grades' => $grades],
        ]);
    }

    #[OA\Post(
        path: '/api/v1/mobile/reference/schools',
        summary: 'Yangi maktab (faqat admin)',
        tags: ['Mobile Reference'],
        security: [['sanctum' => []]],
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['name'],
            properties: [
                new OA\Property(property: 'name', type: 'string', example: '15-sonli maktab'),
                new OA\Property(property: 'short_name', type: 'string', nullable: true),
                new OA\Property(property: 'region', type: 'string', nullable: true),
                new OA\Property(property: 'city', type: 'string', nullable: true),
                new OA\Property(property: 'address', type: 'string', nullable: true),
                new OA\Property(property: 'is_active', type: 'boolean', nullable: true),
            ]
        )
    )]
    #[OA\Response(response: 201, description: 'Yaratildi')]
    #[OA\Response(response: 403, description: 'Admin emas')]
    #[OA\Response(response: 422, description: 'Validatsiya xatosi')]
    public function storeSchool(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user || $user->role !== 'admin') {
            return response()->json([
                'status' => 'fail',
                'data'   => ['message' => 'Bu amalni faqat administrator bajarishi mumkin.'],
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name'       => 'required|string|max:255',
            'short_name' => 'nullable|string|max:120',
            'region'     => 'nullable|string|max:120',
            'city'       => 'nullable|string|max:120',
            'address'    => 'nullable|string|max:500',
            'is_active'  => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $school = $this->schoolRepository->create($validator->validated());

        return response()->json([
            'status' => 'success',
            'data'   => ['school' => $school],
        ], 201);
    }

    #[OA\Post(
        path: '/api/v1/mobile/reference/grades',
        summary: 'Yangi sinf qiymati (faqat admin)',
        tags: ['Mobile Reference'],
        security: [['sanctum' => []]],
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['label'],
            properties: [
                new OA\Property(property: 'label', type: 'string', example: '9-A'),
            ]
        )
    )]
    #[OA\Response(response: 201, description: 'Yaratildi')]
    #[OA\Response(response: 403, description: 'Admin emas')]
    #[OA\Response(response: 422, description: 'Validatsiya xatosi')]
    public function storeGrade(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user || $user->role !== 'admin') {
            return response()->json([
                'status' => 'fail',
                'data'   => ['message' => 'Bu amalni faqat administrator bajarishi mumkin.'],
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'label' => ['required', 'string', 'max:50', Rule::in(GradeLevel::ALLOWED_LABELS), Rule::unique('grade_levels', 'label')],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $maxSort = (int) GradeLevel::query()->max('sort_order');
        $grade = GradeLevel::create([
            'label'      => trim($validator->validated()['label']),
            'sort_order' => $maxSort + 1,
        ]);

        return response()->json([
            'status' => 'success',
            'data'   => ['grade' => $grade],
        ], 201);
    }
}

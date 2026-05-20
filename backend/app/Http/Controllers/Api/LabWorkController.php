<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\LabWorkRepositoryInterface;
use App\Support\LabWorkApiFormatter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'LabWorks', description: 'Laboratoriya ishlari (javoblar bilan)')]
class LabWorkController extends Controller
{
    public function __construct(
        private readonly LabWorkRepositoryInterface $repository
    ) {}

    // ─── GET /lab-works ──────────────────────────────────────────────────────

    #[OA\Get(
        path: '/api/v1/lab-works',
        summary: 'Barcha laboratoriya ishlar ro\'yxati',
        tags: ['LabWorks'],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli'),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $lang = $request->query('lang');
        $labs = $this->repository->all()
            ->map(fn ($lab) => LabWorkApiFormatter::listItem($lab, is_string($lang) ? $lang : null))
            ->values();

        return response()->json(
            ['status' => 'success', 'data' => ['lab_works' => $labs]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // ─── GET /lab-works/{id} ─────────────────────────────────────────────────

    #[OA\Get(
        path: '/api/v1/lab-works/{id}',
        summary: 'Bitta laboratoriya ishi (to\'liq nested ma\'lumot bilan)',
        tags: ['LabWorks'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli'),
            new OA\Response(response: 404, description: 'Topilmadi'),
        ]
    )]
    public function show(Request $request, int $id): JsonResponse
    {
        $lab = $this->repository->find($id);
        if (!$lab) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Laboratoriya topilmadi']], 404);
        }

        $lang = $request->query('lang', 'uz');

        return response()->json(
            [
                'status' => 'success',
                'data'   => ['lab_work' => LabWorkApiFormatter::detail($lab, is_string($lang) ? $lang : 'uz')],
            ],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // ─── POST /lab-works ─────────────────────────────────────────────────────

    #[OA\Post(
        path: '/api/v1/lab-works',
        summary: 'Yangi laboratoriya ishi yaratish',
        tags: ['LabWorks'],
        requestBody: new OA\RequestBody(required: true, content: new OA\JsonContent(
            required: ['number', 'translations'],
            properties: [
                new OA\Property(property: 'number', type: 'integer', example: 6),
                new OA\Property(property: 'status', type: 'string', enum: ['active', 'inactive']),
                new OA\Property(property: 'translations', type: 'array', items: new OA\Items(
                    properties: [
                        new OA\Property(property: 'language_code', type: 'string', example: 'uz'),
                        new OA\Property(property: 'title', type: 'string'),
                        new OA\Property(property: 'description', type: 'string', nullable: true),
                    ]
                )),
            ]
        )),
        responses: [
            new OA\Response(response: 201, description: 'Yaratildi'),
            new OA\Response(response: 422, description: 'Validatsiya xatosi'),
        ]
    )]
    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'number'                           => 'required|integer|min:1|max:255',
            'status'                           => 'nullable|in:active,inactive',
            'translations'                     => 'required|array|min:1',
            'translations.*.language_code'     => 'nullable|string',
            'translations.*.language_id'       => 'nullable|integer',
            'translations.*.title'             => 'required|string|max:255',
            'translations.*.description'       => 'nullable|string',
            'experiments'                      => 'nullable|array',
            'experiments.*.type'               => 'nullable|in:probirka,tajriba,bosqich',
            'experiments.*.order_index'        => 'nullable|integer|min:1',
            'experiments.*.translations'       => 'nullable|array',
            'experiments.*.reactions'          => 'nullable|array',
            'experiments.*.reactions.*.formula' => 'required_with:experiments.*.reactions|string',
            'experiments.*.reactions.*.type'   => 'nullable|in:molecular,full_ionic,short_ionic',
            'experiments.*.observations'       => 'nullable|array',
            'experiments.*.products'           => 'nullable|array',
            'experiments.*.products.*.chemical_formula' => 'required_with:experiments.*.products|string|max:100',
            'experiments.*.products.*.state'   => 'nullable|in:dissolved,precipitate,gas,solid,unknown',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $lab = $this->repository->create($request->all());
        return response()->json(['status' => 'success', 'data' => ['lab_work' => $lab]], 201);
    }

    // ─── PUT /lab-works/{id} ─────────────────────────────────────────────────

    #[OA\Put(
        path: '/api/v1/lab-works/{id}',
        summary: 'Laboratoriya ishini yangilash',
        tags: ['LabWorks'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [
            new OA\Response(response: 200, description: 'Yangilandi'),
            new OA\Response(response: 404, description: 'Topilmadi'),
        ]
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'number'                           => 'nullable|integer|min:1|max:255',
            'status'                           => 'nullable|in:active,inactive',
            'translations'                     => 'nullable|array',
            'translations.*.language_code'     => 'nullable|string',
            'translations.*.language_id'       => 'nullable|integer',
            'translations.*.title'             => 'required_with:translations|string|max:255',
            'experiments'                      => 'nullable|array',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $lab = $this->repository->update($id, $request->all());
        if (!$lab) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Laboratoriya topilmadi']], 404);
        }
        return response()->json(['status' => 'success', 'data' => ['lab_work' => $lab]]);
    }

    // ─── DELETE /lab-works/{id} ───────────────────────────────────────────────

    #[OA\Delete(
        path: '/api/v1/lab-works/{id}',
        summary: 'Laboratoriya ishini o\'chirish',
        tags: ['LabWorks'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [
            new OA\Response(response: 200, description: 'O\'chirildi'),
            new OA\Response(response: 404, description: 'Topilmadi'),
        ]
    )]
    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->repository->delete($id);
        if (!$deleted) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Laboratoriya topilmadi']], 404);
        }
        return response()->json(['status' => 'success', 'data' => null]);
    }
}

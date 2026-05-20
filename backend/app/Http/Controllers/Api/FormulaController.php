<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\FormulaRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

class FormulaController extends Controller
{
    private FormulaRepositoryInterface $repository;

    public function __construct(FormulaRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    #[OA\Get(
        path: '/api/v1/formulas',
        summary: 'Barcha kimyoviy formulalar ro\'yxatini olish',
        tags: ['Formulas'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Muvaffaqiyatli javob',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'status', type: 'string', example: 'success'),
                        new OA\Property(
                            property: 'data',
                            properties: [
                                new OA\Property(
                                    property: 'formulas',
                                    type: 'array',
                                    items: new OA\Items(
                                        properties: [
                                            new OA\Property(property: 'id', type: 'integer', example: 1),
                                            new OA\Property(property: 'formula', type: 'string', example: 'H2O'),
                                            new OA\Property(property: 'molar_mass', type: 'number', format: 'float', example: 18.015),
                                            new OA\Property(property: 'category', type: 'string', example: 'popular'),
                                            new OA\Property(
                                                property: 'translations',
                                                type: 'array',
                                                items: new OA\Items(
                                                    properties: [
                                                        new OA\Property(property: 'id', type: 'integer', example: 1),
                                                        new OA\Property(property: 'name', type: 'string', example: 'Suv'),
                                                        new OA\Property(property: 'language_id', type: 'integer', example: 1)
                                                    ]
                                                )
                                            ),
                                            new OA\Property(
                                                property: 'elements',
                                                type: 'array',
                                                items: new OA\Items(
                                                    properties: [
                                                        new OA\Property(property: 'id', type: 'integer', example: 1),
                                                        new OA\Property(property: 'symbol', type: 'string', example: 'H'),
                                                        new OA\Property(
                                                            property: 'pivot',
                                                            properties: [
                                                                new OA\Property(property: 'amount', type: 'integer', example: 2)
                                                            ],
                                                            type: 'object'
                                                        )
                                                    ]
                                                )
                                            )
                                        ]
                                    )
                                )
                            ],
                            type: 'object'
                        )
                    ]
                )
            )
        ]
    )]
    public function index(): JsonResponse
    {
        $formulas = $this->repository->getAll();
        return response()->json([
            'status' => 'success',
            'data' => ['formulas' => $formulas]
        ]);
    }

    #[OA\Post(
        path: '/api/v1/formulas',
        summary: 'Yangi formula yaratish',
        tags: ['Formulas'],
        security: [['sanctum' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['formula', 'translations'],
                properties: [
                    new OA\Property(property: 'formula', type: 'string', example: 'H2O'),
                    new OA\Property(property: 'molar_mass', type: 'number', example: 18.015),
                    new OA\Property(property: 'category', type: 'string', example: 'popular'),
                    new OA\Property(
                        property: 'translations',
                        type: 'object',
                        additionalProperties: new OA\AdditionalProperties(
                            properties: [
                                new OA\Property(property: 'name', type: 'string', example: 'Suv')
                            ],
                            type: 'object'
                        ),
                        example: [1 => ['name' => 'Suv'], 2 => ['name' => 'Вода']]
                    ),
                    new OA\Property(
                        property: 'elements',
                        type: 'array',
                        items: new OA\Items(
                            properties: [
                                new OA\Property(property: 'element_id', type: 'integer', example: 1),
                                new OA\Property(property: 'amount', type: 'integer', example: 2)
                            ]
                        )
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: 'Muvaffaqiyatli yaratildi',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'status', type: 'string', example: 'success'),
                        new OA\Property(property: 'data', type: 'object')
                    ]
                )
            ),
            new OA\Response(response: 422, description: 'Validatsiya xatosi')
        ]
    )]
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'formula' => 'required|string|max:255',
            'molar_mass' => 'numeric',
            'category' => 'string|max:255',
            'translations' => 'required|array',
            'translations.*.name' => 'required|string|max:255',
            'elements' => 'array',
            'elements.*.element_id' => 'required|exists:elements,id',
            'elements.*.amount' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $formula = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => ['formula' => $formula]
        ], 201);
    }

    #[OA\Get(
        path: '/api/v1/formulas/{id}',
        summary: 'Formula ma\'lumotlarini olish',
        tags: ['Formulas'],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli javob'),
            new OA\Response(response: 404, description: 'Topilmadi')
        ]
    )]
    public function show(int $id): JsonResponse
    {
        $formula = $this->repository->findById($id);

        if (!$formula) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Formula not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['formula' => $formula]
        ]);
    }

    #[OA\Put(
        path: '/api/v1/formulas/{id}',
        summary: 'Formula ma\'lumotlarini yangilash',
        tags: ['Formulas'],
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: 'formula', type: 'string', example: 'H2O'),
                    new OA\Property(property: 'molar_mass', type: 'number', example: 18.015),
                    new OA\Property(property: 'category', type: 'string', example: 'popular'),
                    new OA\Property(property: 'translations', type: 'object'),
                    new OA\Property(
                        property: 'elements',
                        type: 'array',
                        items: new OA\Items(
                            properties: [
                                new OA\Property(property: 'element_id', type: 'integer', example: 1),
                                new OA\Property(property: 'amount', type: 'integer', example: 2)
                            ]
                        )
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli yangilandi'),
            new OA\Response(response: 404, description: 'Topilmadi'),
            new OA\Response(response: 422, description: 'Validatsiya xatosi')
        ]
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'formula' => 'string|max:255',
            'molar_mass' => 'numeric',
            'category' => 'string|max:255',
            'translations' => 'array',
            'translations.*.name' => 'string|max:255',
            'elements' => 'array',
            'elements.*.element_id' => 'required|exists:elements,id',
            'elements.*.amount' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 422);
        }

        $formula = $this->repository->update($id, $request->all());

        if (!$formula) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Formula not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => ['formula' => $formula]
        ]);
    }

    #[OA\Delete(
        path: '/api/v1/formulas/{id}',
        summary: 'Formulani o\'chirish',
        tags: ['Formulas'],
        security: [['sanctum' => []]],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        responses: [
            new OA\Response(response: 204, description: 'Muvaffaqiyatli o\'chirildi'),
            new OA\Response(response: 404, description: 'Topilmadi')
        ]
    )]
    public function destroy(int $id): JsonResponse
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Formula not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

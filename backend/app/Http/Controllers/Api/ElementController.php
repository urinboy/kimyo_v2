<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Element;
use App\Repositories\Interfaces\ElementRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

class ElementController extends Controller
{
    protected $repository;

    public function __construct(ElementRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    #[OA\Get(
        path: '/api/v1/elements',
        summary: 'Barcha kimyoviy elementlar ro\'yxatini olish',
        tags: ['Elements'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Muvaffaqiyatli javob',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'status', type: 'string', example: 'success'),
                        new OA\Property(
                            property: 'data',
                            type: 'object',
                            properties: [
                                new OA\Property(
                                    property: 'elements',
                                    type: 'array',
                                    items: new OA\Items(
                                        properties: [
                                            new OA\Property(property: 'id', type: 'integer', example: 1),
                                            new OA\Property(property: 'atomic_number', type: 'integer', example: 1),
                                            new OA\Property(property: 'symbol', type: 'string', example: 'H'),
                                            new OA\Property(property: 'mass', type: 'number', format: 'float', example: 1.008),
                                            new OA\Property(property: 'type', type: 'string', example: 'nonmetal'),
                                            new OA\Property(property: 'color_hex', type: 'string', example: '#90CAF9'),
                                            new OA\Property(
                                                property: 'translations',
                                                type: 'array',
                                                items: new OA\Items(
                                                    properties: [
                                                        new OA\Property(property: 'language_id', type: 'integer', example: 1),
                                                        new OA\Property(property: 'name', type: 'string', example: 'Vodorod'),
                                                        new OA\Property(property: 'description', type: 'string', example: 'Eng yengil element')
                                                    ]
                                                )
                                            )
                                        ]
                                    )
                                )
                            ]
                        )
                    ]
                )
            )
        ]
    )]
    public function index()
    {
        $elements = $this->repository->all()->map(function (Element $e) {
            return [
                'id' => $e->id,
                'atomic_number' => (int) $e->atomic_number,
                'symbol' => $e->symbol,
                'mass' => is_numeric($e->mass) ? (float) $e->mass : 0.0,
                'color_hex' => $e->color_hex,
                'type' => $e->type,
                'translations' => $e->translations->map(function ($t) {
                    $lang = $t->language;

                    return [
                        'id' => $t->id,
                        'element_id' => $t->element_id,
                        'language_id' => $t->language_id,
                        'name' => $this->utf8Safe($t->name),
                        'description' => $this->utf8Safe($t->description),
                        'language' => $lang ? [
                            'id' => $lang->id,
                            'code' => $lang->code,
                            'name' => $this->utf8Safe($lang->name ?? null),
                        ] : null,
                    ];
                })->values(),
            ];
        });

        return response()->json(
            [
                'status' => 'success',
                'data' => [
                    'elements' => $elements,
                ],
            ],
            200,
            [],
            JSON_INVALID_UTF8_SUBSTITUTE | JSON_UNESCAPED_UNICODE
        );
    }

    private function utf8Safe(?string $value): ?string
    {
        if ($value === null) {
            return null;
        }
        if ($value === '') {
            return '';
        }
        $clean = @iconv('UTF-8', 'UTF-8//IGNORE', $value);
        if ($clean === false) {
            return '';
        }
        // JSON/parser buzuvchi boshqaruv belgilari (vertikal tab, 0x7F va h.k.)
        $clean = preg_replace('/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/u', '', $clean);
        // Zero-width / format belgilari (admin Word dan yopishtirishi mumkin)
        $clean = preg_replace('/[\x{200B}-\x{200D}\x{FEFF}\x{2060}]/u', '', $clean);
        // Qo‘shiqlar / ustunlar uchun maxsus bo‘linishlari — oddiy bo‘shliqqa (JSON uchun xavfsiz)
        $clean = preg_replace('/[\x{2028}\x{2029}\x{0085}]/u', ' ', $clean);
        // “smart” tirnoqlar — oddiy ASCII ga (Dart/ boshqa JSON-parserlar uchun barqaror)
        $clean = str_replace(
            ["\xE2\x80\x9C", "\xE2\x80\x9D", "\xE2\x80\x98", "\xE2\x80\x99", "\xC2\xAB", "\xC2\xBB"],
            ['"', '"', "'", "'", '"', '"'],
            $clean
        );

        return $clean;
    }

    #[OA\Post(
        path: '/api/v1/elements',
        summary: 'Yangi element qo\'shish',
        security: [['sanctum' => []]],
        tags: ['Elements'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['atomic_number', 'symbol', 'mass', 'translations'],
                properties: [
                    new OA\Property(property: 'atomic_number', type: 'integer', example: 119),
                    new OA\Property(property: 'symbol', type: 'string', example: 'Uue'),
                    new OA\Property(property: 'mass', type: 'number', format: 'float', example: 315.0),
                    new OA\Property(property: 'type', type: 'string', example: 'alkali'),
                    new OA\Property(property: 'color_hex', type: 'string', example: '#FF8A80'),
                    new OA\Property(
                        property: 'translations',
                        type: 'array',
                        items: new OA\Items(
                            properties: [
                                new OA\Property(property: 'language_id', type: 'integer', example: 1),
                                new OA\Property(property: 'name', type: 'string', example: 'Ununenniy'),
                                new OA\Property(property: 'description', type: 'string', example: 'Gipotetik element')
                            ]
                        )
                    )
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Element yaratildi'),
            new OA\Response(response: 400, description: 'Validatsiya xatosi'),
            new OA\Response(response: 401, description: 'Avtorizatsiyadan o\'tilmagan'),
        ]
    )]
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'atomic_number' => 'required|integer|unique:elements,atomic_number',
            'symbol'        => 'required|string|max:10|unique:elements,symbol',
            'mass'          => 'required|numeric',
            'color_hex'     => 'nullable|string|max:7',
            'type'          => 'nullable|string|max:50',
            'translations'  => 'required|array|min:1',
            'translations.*.language_id' => 'required|exists:languages,id',
            'translations.*.name'        => 'required|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $element = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'element' => $element
            ]
        ], 201);
    }

    #[OA\Get(
        path: '/api/v1/elements/{id}',
        summary: 'Element ma\'lumotlarini ID orqali olish',
        tags: ['Elements'],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli javob'),
            new OA\Response(response: 404, description: 'Element topilmadi'),
        ]
    )]
    public function show($id)
    {
        $element = $this->repository->find($id);

        if (!$element) {
            return response()->json([
                'status' => 'error',
                'message' => 'Element not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'element' => $element
            ]
        ]);
    }

    #[OA\Put(
        path: '/api/v1/elements/{id}',
        summary: 'Element ma\'lumotlarini yangilash',
        security: [['sanctum' => []]],
        tags: ['Elements'],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        responses: [
            new OA\Response(response: 200, description: 'Element yangilandi'),
            new OA\Response(response: 404, description: 'Element topilmadi'),
        ]
    )]
    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'atomic_number' => 'sometimes|integer|unique:elements,atomic_number,' . $id,
            'symbol'        => 'sometimes|string|max:10|unique:elements,symbol,' . $id,
            'mass'          => 'sometimes|numeric',
            'color_hex'     => 'nullable|string|max:7',
            'type'          => 'nullable|string|max:50',
            'translations'  => 'sometimes|array',
            'translations.*.language_id' => 'required_with:translations|exists:languages,id',
            'translations.*.name'        => 'required_with:translations|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $element = $this->repository->update($id, $request->all());

        if (!$element) {
            return response()->json([
                'status' => 'error',
                'message' => 'Element not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'element' => $element
            ]
        ]);
    }

    #[OA\Delete(
        path: '/api/v1/elements/{id}',
        summary: 'Elementni o\'chirish',
        security: [['sanctum' => []]],
        tags: ['Elements'],
        parameters: [
            new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))
        ],
        responses: [
            new OA\Response(response: 204, description: 'Element o\'chirildi'),
            new OA\Response(response: 404, description: 'Element topilmadi'),
        ]
    )]
    public function destroy($id)
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'Element not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

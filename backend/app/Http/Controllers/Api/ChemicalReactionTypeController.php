<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChemicalReactionType;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

class ChemicalReactionTypeController extends Controller
{
    private function normalizeHex(string $v): string
    {
        $s = ltrim(trim($v), '#');
        if (strlen($s) > 6) {
            $s = substr($s, -6);
        }

        return strtoupper($s);
    }

    #[OA\Post(
        path: '/api/v1/chemical-reaction-types',
        summary: 'Kimyoviy reaksiya turini yaratish',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['name_uz', 'formula', 'color_hex', 'icon_color_hex'],
                properties: [
                    new OA\Property(property: 'name_uz', type: 'string', example: 'Birikish reaksiyasi'),
                    new OA\Property(property: 'name_ru', type: 'string', nullable: true),
                    new OA\Property(property: 'name_en', type: 'string', nullable: true),
                    new OA\Property(property: 'name_kaa', type: 'string', nullable: true),
                    new OA\Property(property: 'formula', type: 'string', example: 'A + B → AB'),
                    new OA\Property(property: 'color_hex', type: 'string', example: 'E8F5E9'),
                    new OA\Property(property: 'icon_color_hex', type: 'string', example: '4CAF50'),
                    new OA\Property(property: 'order', type: 'integer', example: 0),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Yaratildi'),
            new OA\Response(response: 401, description: 'Avtorizatsiya talab qilinadi'),
            new OA\Response(response: 422, description: 'Validatsiya xatosi'),
        ]
    )]
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name_uz' => 'required|string|max:255',
            'name_ru' => 'nullable|string|max:255',
            'name_en' => 'nullable|string|max:255',
            'name_kaa' => 'nullable|string|max:255',
            'formula' => 'required|string|max:255',
            'description_uz' => 'nullable|string',
            'description_ru' => 'nullable|string',
            'description_en' => 'nullable|string',
            'description_kaa' => 'nullable|string',
            'modal_formula' => 'nullable|string',
            'modal_badge_uz' => 'nullable|string|max:255',
            'modal_badge_ru' => 'nullable|string|max:255',
            'modal_badge_en' => 'nullable|string|max:255',
            'modal_badge_kaa' => 'nullable|string|max:255',
            'examples' => 'nullable|array',
            'examples.*' => 'string|max:500',
            'color_hex' => 'required|string',
            'icon_color_hex' => 'required|string',
            'order' => 'nullable|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validatsiya xatosi',
                'errors' => $validator->errors(),
            ], 422);
        }
        $data = $validator->validated();
        foreach (['color_hex', 'icon_color_hex'] as $k) {
            $norm = $this->normalizeHex($data[$k]);
            if (! preg_match('/^[0-9A-Fa-f]{6}$/', $norm)) {
                return response()->json([
                    'status' => 'fail',
                    'message' => "Noto'g'ri hex rang: {$k} (6 ta hex raqam, # ixtiyoriy)",
                ], 422);
            }
            $data[$k] = $norm;
        }
        $data['order'] = $data['order'] ?? 0;
        if (array_key_exists('examples', $data) && is_array($data['examples'])) {
            $data['examples'] = array_values(array_filter($data['examples'], fn ($e) => is_string($e) && $e !== ''));
        }
        $type = ChemicalReactionType::query()->create($data);

        return response()->json([
            'status' => 'success',
            'data' => ['reaction_type' => $type],
        ], 201);
    }

    #[OA\Put(
        path: '/api/v1/chemical-reaction-types/{chemical_reaction_type}',
        summary: 'Reaksiya turini yangilash',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        parameters: [
            new OA\Parameter(name: 'chemical_reaction_type', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli'),
            new OA\Response(response: 401, description: 'Avtorizatsiya talab qilinadi'),
            new OA\Response(response: 404, description: 'Topilmadi'),
            new OA\Response(response: 422, description: 'Validatsiya xatosi'),
        ]
    )]
    public function update(Request $request, ChemicalReactionType $chemicalReactionType): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name_uz' => 'sometimes|required|string|max:255',
            'name_ru' => 'nullable|string|max:255',
            'name_en' => 'nullable|string|max:255',
            'name_kaa' => 'nullable|string|max:255',
            'formula' => 'sometimes|required|string|max:255',
            'description_uz' => 'nullable|string',
            'description_ru' => 'nullable|string',
            'description_en' => 'nullable|string',
            'description_kaa' => 'nullable|string',
            'modal_formula' => 'nullable|string',
            'modal_badge_uz' => 'nullable|string|max:255',
            'modal_badge_ru' => 'nullable|string|max:255',
            'modal_badge_en' => 'nullable|string|max:255',
            'modal_badge_kaa' => 'nullable|string|max:255',
            'examples' => 'nullable|array',
            'examples.*' => 'string|max:500',
            'color_hex' => 'sometimes|required|string',
            'icon_color_hex' => 'sometimes|required|string',
            'order' => 'nullable|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validatsiya xatosi',
                'errors' => $validator->errors(),
            ], 422);
        }
        $data = $validator->validated();
        foreach (['color_hex', 'icon_color_hex'] as $k) {
            if (array_key_exists($k, $data)) {
                $norm = $this->normalizeHex($data[$k]);
                if (! preg_match('/^[0-9A-Fa-f]{6}$/', $norm)) {
                    return response()->json([
                        'status' => 'fail',
                        'message' => "Noto'g'ri hex rang: {$k}",
                    ], 422);
                }
                $data[$k] = $norm;
            }
        }
        if (array_key_exists('examples', $data) && is_array($data['examples'])) {
            $data['examples'] = array_values(array_filter($data['examples'], fn ($e) => is_string($e) && $e !== ''));
        }
        $chemicalReactionType->update($data);

        return response()->json([
            'status' => 'success',
            'data' => ['reaction_type' => $chemicalReactionType->fresh()],
        ]);
    }

    #[OA\Delete(
        path: '/api/v1/chemical-reaction-types/{chemical_reaction_type}',
        summary: 'Reaksiya turini o‘chirish',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        parameters: [
            new OA\Parameter(name: 'chemical_reaction_type', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'O‘chirildi'),
            new OA\Response(response: 401, description: 'Avtorizatsiya talab qilinadi'),
        ]
    )]
    public function destroy(ChemicalReactionType $chemicalReactionType): JsonResponse
    {
        $chemicalReactionType->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }
}

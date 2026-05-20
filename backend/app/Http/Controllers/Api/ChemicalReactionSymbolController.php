<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChemicalReactionSymbol;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

class ChemicalReactionSymbolController extends Controller
{
    #[OA\Post(
        path: '/api/v1/chemical-reaction-symbols',
        summary: 'Reaksiya shartli belgisini yaratish',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['symbol', 'desc_uz'],
                properties: [
                    new OA\Property(property: 'symbol', type: 'string', example: '↑'),
                    new OA\Property(property: 'desc_uz', type: 'string'),
                    new OA\Property(property: 'desc_ru', type: 'string', nullable: true),
                    new OA\Property(property: 'desc_en', type: 'string', nullable: true),
                    new OA\Property(property: 'desc_kaa', type: 'string', nullable: true),
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
            'symbol' => 'required|string|max:16',
            'desc_uz' => 'required|string|max:255',
            'desc_ru' => 'nullable|string|max:255',
            'desc_en' => 'nullable|string|max:255',
            'desc_kaa' => 'nullable|string|max:255',
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
        $data['order'] = $data['order'] ?? 0;
        $symbol = ChemicalReactionSymbol::query()->create($data);

        return response()->json([
            'status' => 'success',
            'data' => ['reaction_symbol' => $symbol],
        ], 201);
    }

    #[OA\Put(
        path: '/api/v1/chemical-reaction-symbols/{chemical_reaction_symbol}',
        summary: 'Shartli belgini yangilash',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        parameters: [
            new OA\Parameter(name: 'chemical_reaction_symbol', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli'),
            new OA\Response(response: 401, description: 'Avtorizatsiya talab qilinadi'),
            new OA\Response(response: 404, description: 'Topilmadi'),
        ]
    )]
    public function update(Request $request, ChemicalReactionSymbol $chemicalReactionSymbol): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'symbol' => 'sometimes|required|string|max:16',
            'desc_uz' => 'sometimes|required|string|max:255',
            'desc_ru' => 'nullable|string|max:255',
            'desc_en' => 'nullable|string|max:255',
            'desc_kaa' => 'nullable|string|max:255',
            'order' => 'nullable|integer|min:0',
        ]);
        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Validatsiya xatosi',
                'errors' => $validator->errors(),
            ], 422);
        }
        $chemicalReactionSymbol->update($validator->validated());

        return response()->json([
            'status' => 'success',
            'data' => ['reaction_symbol' => $chemicalReactionSymbol->fresh()],
        ]);
    }

    #[OA\Delete(
        path: '/api/v1/chemical-reaction-symbols/{chemical_reaction_symbol}',
        summary: 'Shartli belgini o‘chirish',
        security: [['sanctum' => []]],
        tags: ['Chemical reactions'],
        parameters: [
            new OA\Parameter(name: 'chemical_reaction_symbol', in: 'path', required: true, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'O‘chirildi'),
            new OA\Response(response: 401, description: 'Avtorizatsiya talab qilinadi'),
        ]
    )]
    public function destroy(ChemicalReactionSymbol $chemicalReactionSymbol): JsonResponse
    {
        $chemicalReactionSymbol->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }
}

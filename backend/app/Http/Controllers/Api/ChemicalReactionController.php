<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChemicalReactionSymbol;
use App\Models\ChemicalReactionType;
use Illuminate\Http\JsonResponse;
use OpenApi\Attributes as OA;

class ChemicalReactionController extends Controller
{
    /**
     * Kimyoviy reaksiya turlari va reaksiyada ishlatiladigan shartli belgilar.
     * Mobil / klient: avvalg hardkod o‘rniga.
     */
    #[OA\Get(
        path: '/api/v1/chemical-reactions',
        summary: 'Reaksiya turlari va shartli belgilar (umumiy ro‘yxat)',
        tags: ['Chemical reactions'],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Muvaffaqiyatli',
                content: new OA\JsonContent(
                    properties: [
                        new OA\Property(property: 'status', type: 'string', example: 'success'),
                        new OA\Property(
                            property: 'data',
                            type: 'object',
                            properties: [
                                new OA\Property(property: 'reaction_types', type: 'array', items: new OA\Items(type: 'object')),
                                new OA\Property(property: 'reaction_symbols', type: 'array', items: new OA\Items(type: 'object')),
                            ]
                        ),
                    ]
                )
            ),
        ]
    )]
    public function index(): JsonResponse
    {
        $types = ChemicalReactionType::query()->orderBy('order')->orderBy('id')->get();
        $symbols = ChemicalReactionSymbol::query()->orderBy('order')->orderBy('id')->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'reaction_types' => $types,
                'reaction_symbols' => $symbols,
            ],
        ]);
    }
}

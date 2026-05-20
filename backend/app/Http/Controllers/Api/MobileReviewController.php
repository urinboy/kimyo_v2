<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Mobile Reviews', description: "Mobil ilova — baholash (ilovani reyting qo'yish)")]
class MobileReviewController extends Controller
{
    /**
     * Ilovaning umumiy reytingini qaytaradi.
     * Auth talab qilinmaydi.
     */
    #[OA\Get(
        path: '/api/v1/mobile/reviews/summary',
        summary: 'Reyting xulosasi',
        description: "Ilovaning o'rtacha reytingi, jami baholashlar soni va yulduz bo'yicha taqsimot.",
        tags: ['Mobile Reviews']
    )]
    #[OA\Response(
        response: 200,
        description: 'Muvaffaqiyatli',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'average_rating', type: 'number', format: 'float', example: 4.7),
                    new OA\Property(property: 'total_reviews',  type: 'integer', example: 128),
                    new OA\Property(property: 'distribution', type: 'object', properties: [
                        new OA\Property(property: '5', type: 'integer', example: 80),
                        new OA\Property(property: '4', type: 'integer', example: 30),
                        new OA\Property(property: '3', type: 'integer', example: 10),
                        new OA\Property(property: '2', type: 'integer', example: 5),
                        new OA\Property(property: '1', type: 'integer', example: 3),
                    ]),
                ]),
            ]
        )
    )]
    public function summary(): JsonResponse
    {
        $total = Review::count();

        $average = $total > 0
            ? round(Review::avg('rating'), 1)
            : 0.0;

        $distribution = [];
        for ($i = 5; $i >= 1; $i--) {
            $distribution[(string) $i] = Review::where('rating', $i)->count();
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'average_rating' => $average,
                'total_reviews'  => $total,
                'distribution'   => $distribution,
            ],
        ]);
    }

    /**
     * Kirgan foydalanuvchining (Bearer token) bahosi — UI da ko‘rsatish uchun.
     */
    #[OA\Get(
        path: '/api/v1/mobile/reviews/me',
        summary: 'Mening bahoam',
        description: "Sanctum token bilan joriy user uchun saqlangan review yoki null.",
        tags: ['Mobile Reviews'],
        security: [['sanctum' => []]],
    )]
    #[OA\Response(
        response: 200,
        description: 'Muvaffaqiyatli',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(
                        property: 'review',
                        nullable: true,
                        type: 'object',
                        properties: [
                            new OA\Property(property: 'id', type: 'integer', example: 1),
                            new OA\Property(property: 'rating', type: 'integer', example: 5),
                            new OA\Property(property: 'comment', type: 'string', nullable: true),
                            new OA\Property(property: 'created_at', type: 'string', format: 'date-time'),
                        ]
                    ),
                ]),
            ]
        )
    )]
    #[OA\Response(response: 401, description: 'Token yo‘q yoki yaroqsiz')]
    public function myReview(): JsonResponse
    {
        $userId = auth('sanctum')->id();
        if (! $userId) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['message' => 'Unauthenticated'],
            ], 401);
        }

        $review = Review::where('user_id', $userId)->first();

        return response()->json([
            'status' => 'success',
            'data'   => [
                'review' => $review ? [
                    'id'         => $review->id,
                    'rating'     => $review->rating,
                    'comment'    => $review->comment,
                    'created_at' => $review->created_at?->toIso8601String(),
                ] : null,
            ],
        ]);
    }

    /**
     * Foydalanuvchi ilovani baholaydi.
     * Auth ixtiyoriy: token bo'lsa user_id saqlanadi, bo'lmasa null.
     */
    #[OA\Post(
        path: '/api/v1/mobile/reviews',
        summary: 'Ilovani baholash',
        description: "1–5 yulduz va ixtiyoriy izoh bilan baholash yuborish. Token bo'lsa user_id bog'lanadi, bo'lmasa anonim saqlanadi.",
        tags: ['Mobile Reviews']
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['rating'],
            properties: [
                new OA\Property(property: 'rating',  type: 'integer', minimum: 1, maximum: 5, example: 5,
                    description: '1 dan 5 gacha yulduz'),
                new OA\Property(property: 'comment', type: 'string',  nullable: true, example: 'Juda yaxshi ilova!',
                    description: 'Ixtiyoriy izoh'),
            ]
        )
    )]
    #[OA\Response(
        response: 201,
        description: 'Baholash muvaffaqiyatli yuborildi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'review', type: 'object', properties: [
                        new OA\Property(property: 'id',          type: 'integer', example: 42),
                        new OA\Property(property: 'rating',      type: 'integer', example: 5),
                        new OA\Property(property: 'comment',     type: 'string',  nullable: true, example: 'Juda yaxshi!'),
                        new OA\Property(property: 'user_id',     type: 'integer', nullable: true, example: 5),
                        new OA\Property(property: 'device_info', type: 'string',  example: 'Android 13 / SM-A525F'),
                        new OA\Property(property: 'created_at',  type: 'string',  format: 'date-time'),
                    ]),
                ]),
            ]
        )
    )]
    #[OA\Response(
        response: 400,
        description: 'Validation xatosi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'fail'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'rating', type: 'array',
                        items: new OA\Items(type: 'string', example: 'The rating field is required.')),
                ]),
            ]
        )
    )]
    #[OA\Response(
        response: 409,
        description: "Foydalanuvchi allaqachon baholagan",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'fail'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'message', type: 'string', example: "Siz allaqachon baholagan siz."),
                ]),
            ]
        )
    )]
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'rating'  => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 400);
        }

        // Token bilan kelgan bo'lsa foydalanuvchini aniqlaymiz (ixtiyoriy)
        $userId = auth('sanctum')->id();

        // Bir foydalanuvchi ikki marta baholamasligini tekshiramiz
        if ($userId && Review::where('user_id', $userId)->exists()) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['message' => 'Siz allaqachon baholagan siz.'],
            ], 409);
        }

        $review = Review::create([
            'user_id'     => $userId,
            'rating'      => $request->rating,
            'comment'     => $request->comment,
            'device_info' => $request->header('User-Agent'),
        ]);

        return response()->json([
            'status' => 'success',
            'data'   => ['review' => $review],
        ], 201);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\MobileAuthRepositoryInterface;
use App\Support\KarakalpakDistricts;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Mobile Auth', description: "Mobil ilova uchun ro'yxatdan o'tish va kirish")]
class MobileAuthController extends Controller
{
    public function __construct(
        protected MobileAuthRepositoryInterface $mobileAuthRepository
    ) {}

    #[OA\Post(
        path: '/api/v1/mobile/auth/register',
        summary: "Ro'yxatdan o'tish",
        description: "Yangi mobil foydalanuvchi yaratish. Role avtomatik 'user' belgilanadi.",
        tags: ['Mobile Auth']
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['name', 'username', 'password', 'password_confirmation'],
            properties: [
                new OA\Property(property: 'name',                  type: 'string',  example: 'Ali Valiyev'),
                new OA\Property(property: 'username',              type: 'string',  example: 'ellikqala_m2_9a_001'),
                new OA\Property(property: 'phone',                 type: 'string',  nullable: true, example: '998901234567'),
                new OA\Property(property: 'district',              type: 'string',  nullable: true, example: 'Ellikkala tumani'),
                new OA\Property(property: 'school_number',         type: 'integer', nullable: true, example: 2),
                new OA\Property(property: 'password',              type: 'string',  format: 'password', example: 'secret123'),
                new OA\Property(property: 'password_confirmation', type: 'string',  format: 'password', example: 'secret123'),
            ]
        )
    )]
    #[OA\Response(
        response: 201,
        description: "Muvaffaqiyatli ro'yxatdan o'tildi",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'user', type: 'object', properties: [
                        new OA\Property(property: 'id',       type: 'integer', example: 5),
                        new OA\Property(property: 'name',     type: 'string',  example: 'Ali Valiyev'),
                        new OA\Property(property: 'username', type: 'string',  example: 'ellikqala_m2_9a_001'),
                        new OA\Property(property: 'email',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'phone',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'role',     type: 'string',  example: 'user'),
                    ]),
                    new OA\Property(property: 'token', type: 'string', example: '1|abc123...'),
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
                new OA\Property(property: 'data',   type: 'object', properties: [
                    new OA\Property(property: 'username', type: 'array', items: new OA\Items(type: 'string', example: 'The username has already been taken.')),
                ]),
            ]
        )
    )]
    public function register(Request $request): JsonResponse
    {
        $request->merge([
            'username' => strtolower(trim((string) $request->input('username'))),
            'phone' => $request->filled('phone') ? trim((string) $request->input('phone')) : null,
        ]);

        $validator = Validator::make($request->all(), [
            'name'          => 'required|string|max:255',
            'username'      => ['required', 'string', 'min:3', 'max:64', 'regex:/^[a-zA-Z0-9._-]+$/', Rule::unique('users', 'username')],
            'phone'         => ['nullable', 'string', 'max:32', Rule::unique('users', 'phone')],
            'district'      => ['nullable', 'string', 'max:120', Rule::in(KarakalpakDistricts::NAMES)],
            'school_number' => 'nullable|integer|min:1|max:100',
            'password'      => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 400);
        }

        $result = $this->mobileAuthRepository->register($validator->validated());

        return response()->json([
            'status' => 'success',
            'data'   => [
                'user'  => $result['user'],
                'token' => $result['token'],
            ],
        ], 201);
    }

    #[OA\Post(
        path: '/api/v1/mobile/auth/login',
        summary: 'Kirish (mobil foydalanuvchi)',
        description: "Mobil foydalanuvchi uchun login. Admin roli bilan kirish taqiqlangan.",
        tags: ['Mobile Auth']
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['login', 'password'],
            properties: [
                new OA\Property(property: 'login',    type: 'string', example: 'ellikqala_m2_9a_001'),
                new OA\Property(property: 'password', type: 'string', format: 'password', example: 'secret123'),
            ]
        )
    )]
    #[OA\Response(
        response: 200,
        description: 'Muvaffaqiyatli kirildi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'user', type: 'object', properties: [
                        new OA\Property(property: 'id',       type: 'integer', example: 5),
                        new OA\Property(property: 'name',     type: 'string',  example: 'Ali Valiyev'),
                        new OA\Property(property: 'username', type: 'string',  example: 'ellikqala_m2_9a_001'),
                        new OA\Property(property: 'email',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'phone',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'role',     type: 'string',  example: 'user'),
                    ]),
                    new OA\Property(property: 'token', type: 'string', example: '1|abc123...'),
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
                new OA\Property(property: 'data',   type: 'object'),
            ]
        )
    )]
    #[OA\Response(
        response: 401,
        description: "Login yoki parol noto'g'ri",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'fail'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'message', type: 'string', example: "Login yoki parol noto'g'ri"),
                ]),
            ]
        )
    )]
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'login'    => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 400);
        }

        $result = $this->mobileAuthRepository->login($request->only('login', 'password'));

        if (!$result) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['message' => "Login yoki parol noto'g'ri"],
            ], 401);
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'user'  => $result['user'],
                'token' => $result['token'],
            ],
        ], 200);
    }

    #[OA\Post(
        path: '/api/v1/mobile/auth/logout',
        summary: 'Chiqish',
        description: 'Joriy access token-ni o\'chiradi.',
        tags: ['Mobile Auth'],
        security: [['sanctum' => []]]
    )]
    #[OA\Response(
        response: 200,
        description: 'Muvaffaqiyatli chiqildi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data',   type: 'null',   example: null),
            ]
        )
    )]
    #[OA\Response(
        response: 401,
        description: 'Autentifikatsiya talab qilinadi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status',  type: 'string', example: 'error'),
                new OA\Property(property: 'message', type: 'string', example: 'Unauthenticated.'),
            ]
        )
    )]
    public function logout(): JsonResponse
    {
        $this->mobileAuthRepository->logout();

        return response()->json([
            'status' => 'success',
            'data'   => null,
        ], 200);
    }

    #[OA\Get(
        path: '/api/v1/mobile/auth/me',
        summary: 'Joriy foydalanuvchi',
        description: "Token orqali autentifikatsiya qilingan foydalanuvchi ma'lumotlarini qaytaradi.",
        tags: ['Mobile Auth'],
        security: [['sanctum' => []]]
    )]
    #[OA\Response(
        response: 200,
        description: "Foydalanuvchi ma'lumotlari",
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object', properties: [
                    new OA\Property(property: 'user', type: 'object', properties: [
                        new OA\Property(property: 'id',       type: 'integer', example: 5),
                        new OA\Property(property: 'name',     type: 'string',  example: 'Ali Valiyev'),
                        new OA\Property(property: 'username', type: 'string',  example: 'ellikqala_m2_9a_001'),
                        new OA\Property(property: 'email',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'phone',    type: 'string',  nullable: true, example: null),
                        new OA\Property(property: 'role',     type: 'string',  example: 'user'),
                    ]),
                ]),
            ]
        )
    )]
    #[OA\Response(
        response: 401,
        description: 'Autentifikatsiya talab qilinadi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status',  type: 'string', example: 'error'),
                new OA\Property(property: 'message', type: 'string', example: 'Unauthenticated.'),
            ]
        )
    )]
    public function me(): JsonResponse
    {
        $user = $this->mobileAuthRepository->getMe();

        return response()->json([
            'status' => 'success',
            'data'   => ['user' => $user],
        ], 200);
    }

    /**
     * Profil: ism, telefon, ta'lim (maktab, sinf). Email mobil tahrirda qabul qilinmaydi.
     */
    #[OA\Put(
        path: '/api/v1/mobile/auth/profile',
        summary: 'Profilni yangilash',
        tags: ['Mobile Auth'],
        security: [['sanctum' => []]],
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'name', type: 'string', example: 'Ali Valiyev'),
                new OA\Property(property: 'username', type: 'string', nullable: true),
                new OA\Property(property: 'phone', type: 'string', nullable: true),
                new OA\Property(property: 'school_name', type: 'string', nullable: true),
                new OA\Property(property: 'grade', type: 'string', nullable: true, example: '9-sinf'),
            ]
        )
    )]
    #[OA\Response(
        response: 200,
        description: 'Yangilandi',
        content: new OA\JsonContent(
            properties: [
                new OA\Property(property: 'status', type: 'string', example: 'success'),
                new OA\Property(property: 'data', type: 'object'),
            ]
        )
    )]
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'name'         => 'sometimes|required|string|max:255',
            'username'     => ['sometimes', 'required', 'string', 'min:3', 'max:64', 'regex:/^[a-zA-Z0-9._-]+$/', Rule::unique('users', 'username')->ignore($user->id)],
            'phone'        => ['nullable', 'string', 'max:32', Rule::unique('users', 'phone')->ignore($user->id)],
            'school_name'  => 'nullable|string|max:255',
            'grade'        => ['nullable', 'string', 'max:50', Rule::exists('grade_levels', 'label')],
            'school_id'    => ['nullable', 'integer', 'exists:schools,id'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $data = $validator->validated();
        $updated = $this->mobileAuthRepository->updateProfile($data);

        return response()->json([
            'status' => 'success',
            'data'   => ['user' => $updated],
        ], 200);
    }

    #[OA\Put(
        path: '/api/v1/mobile/auth/password',
        summary: 'Parolni almashtirish',
        description: "Joriy parol tekshiriladi; yangi parol `password_confirmation` bilan tasdiqlanadi.",
        tags: ['Mobile Auth'],
        security: [['sanctum' => []]],
    )]
    #[OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['current_password', 'password', 'password_confirmation'],
            properties: [
                new OA\Property(property: 'current_password', type: 'string', format: 'password'),
                new OA\Property(property: 'password', type: 'string', format: 'password'),
                new OA\Property(property: 'password_confirmation', type: 'string', format: 'password'),
            ]
        )
    )]
    #[OA\Response(response: 200, description: 'Parol yangilandi')]
    #[OA\Response(response: 422, description: 'Validatsiya yoki joriy parol xato')]
    public function changePassword(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'current_password'      => 'required|string',
            'password'              => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data'   => $validator->errors(),
            ], 422);
        }

        $ok = $this->mobileAuthRepository->changePassword(
            $validator->validated()['current_password'],
            $validator->validated()['password']
        );

        if (! $ok) {
            return response()->json([
                'status' => 'fail',
                'data'   => [
                    'current_password' => ["Joriy parol noto'g'ri."],
                ],
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'data'   => null,
        ], 200);
    }
}

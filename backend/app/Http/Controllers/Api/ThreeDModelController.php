<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\ThreeDModelRepositoryInterface;
use App\Support\ThreeDModelApiFormatter;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use OpenApi\Attributes as OA;

#[OA\Tag(name: '3D Models', description: '3D element modellari (GLB/GLTF fayllar)')]
class ThreeDModelController extends Controller
{
    public function __construct(
        private readonly ThreeDModelRepositoryInterface $repository,
    ) {}

    // -------------------------------------------------------------------------
    // GET /api/v1/3d-models
    // -------------------------------------------------------------------------
    #[OA\Get(
        path: '/api/v1/3d-models',
        summary: '3D modellar ro\'yxati',
        tags: ['3D Models'],
        parameters: [
            new OA\Parameter(name: 'lang', in: 'query', required: false, schema: new OA\Schema(type: 'string')),
            new OA\Parameter(name: 'element_id', in: 'query', required: false, schema: new OA\Schema(type: 'integer')),
        ],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function index(Request $request): JsonResponse
    {
        $activeOnly = ! $request->user('sanctum');
        $models = $this->repository->all($activeOnly);

        if ($request->filled('element_id')) {
            $models = $models->where('element_id', (int) $request->element_id)->values();
        }

        $lang = $request->input('lang', 'uz');
        $withTranslations = $request->boolean('with_translations');

        $data = $models->map(fn($m) => $withTranslations
            ? ThreeDModelApiFormatter::adminResource($m)
            : ThreeDModelApiFormatter::listItem($m, $lang)
        )->values();

        return response()->json(
            ['status' => 'success', 'data' => ['three_d_models' => $data]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // -------------------------------------------------------------------------
    // GET /api/v1/3d-models/{id}
    // -------------------------------------------------------------------------
    #[OA\Get(
        path: '/api/v1/3d-models/{id}',
        summary: 'Bitta 3D model',
        tags: ['3D Models'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [new OA\Response(response: 200, description: 'OK'), new OA\Response(response: 404, description: 'Not Found')]
    )]
    public function show(Request $request, int $id): JsonResponse
    {
        $model = $this->repository->find($id);

        if (! $model) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Topilmadi']], 404);
        }

        $lang = $request->input('lang', 'uz');
        $withTranslations = $request->boolean('with_translations');
        $data = $withTranslations
            ? ThreeDModelApiFormatter::adminResource($model)
            : ThreeDModelApiFormatter::listItem($model, $lang);

        return response()->json(
            ['status' => 'success', 'data' => ['three_d_model' => $data]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // -------------------------------------------------------------------------
    // POST /api/v1/3d-models  (multipart/form-data)
    // -------------------------------------------------------------------------
    #[OA\Post(
        path: '/api/v1/3d-models',
        summary: 'Yangi 3D model yaratish',
        tags: ['3D Models'],
        security: [['sanctum' => []]],
        responses: [new OA\Response(response: 201, description: 'Created'), new OA\Response(response: 422, description: 'Validation error')]
    )]
    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'slug'                     => 'required|string|max:100|unique:three_d_models,slug',
            'element_id'               => 'nullable|integer|exists:elements,id',
            'sort_order'               => 'nullable|integer|min:0',
            'is_active'                => 'nullable|boolean',
            'model_file'               => 'nullable|file|mimes:glb,gltf|max:102400',
            'translations'             => 'required|array|min:1',
            'translations.*.language_code' => 'required|string|exists:languages,code',
            'translations.*.name'      => 'required|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $modelPath = null;
        if ($request->hasFile('model_file')) {
            $result = $this->storeModelFile($request);
            if ($result instanceof JsonResponse) {
                return $result;
            }
            $modelPath = $result;
        }

        $translations = $this->parseTranslations($request);

        $model = $this->repository->create([
            'slug'        => $request->input('slug'),
            'model_path'  => $modelPath,
            'element_id'  => $request->input('element_id'),
            'sort_order'  => $request->input('sort_order', 0),
            'is_active'   => filter_var($request->input('is_active', true), FILTER_VALIDATE_BOOLEAN),
            'translations' => $translations,
        ]);

        return response()->json(
            ['status' => 'success', 'data' => ['three_d_model' => ThreeDModelApiFormatter::adminResource($model)]],
            201,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // -------------------------------------------------------------------------
    // PUT /api/v1/3d-models/{id}  or  POST /api/v1/3d-models/{id}
    // -------------------------------------------------------------------------
    #[OA\Put(
        path: '/api/v1/3d-models/{id}',
        summary: '3D modelni tahrirlash',
        tags: ['3D Models'],
        security: [['sanctum' => []]],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [new OA\Response(response: 200, description: 'OK'), new OA\Response(response: 404, description: 'Not Found')]
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        $existing = $this->repository->find($id);
        if (! $existing) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Topilmadi']], 404);
        }

        $v = Validator::make($request->all(), [
            'slug'                     => "required|string|max:100|unique:three_d_models,slug,{$id}",
            'element_id'               => 'nullable|integer|exists:elements,id',
            'sort_order'               => 'nullable|integer|min:0',
            'is_active'                => 'nullable|boolean',
            'model_file'               => 'nullable|file|mimes:glb,gltf|max:102400',
            'remove_model_file'        => 'nullable|boolean',
            'translations'             => 'nullable|array',
            'translations.*.language_code' => 'required_with:translations|string|exists:languages,code',
            'translations.*.name'      => 'required_with:translations|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $data = [
            'slug'       => $request->input('slug'),
            'element_id' => $request->input('element_id'),
            'sort_order' => $request->input('sort_order', $existing->sort_order),
            'is_active'  => filter_var($request->input('is_active', $existing->is_active), FILTER_VALIDATE_BOOLEAN),
        ];

        // Fayl yuklanishi
        if ($request->hasFile('model_file')) {
            $result = $this->storeModelFile($request);
            if ($result instanceof JsonResponse) {
                return $result;
            }
            $data['model_path'] = $result;
        } elseif (filter_var($request->input('remove_model_file', false), FILTER_VALIDATE_BOOLEAN)) {
            $data['model_path'] = null;
        }

        if ($request->has('translations')) {
            $data['translations'] = $this->parseTranslations($request);
        }

        $model = $this->repository->update($id, $data);

        return response()->json(
            ['status' => 'success', 'data' => ['three_d_model' => ThreeDModelApiFormatter::adminResource($model)]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    // -------------------------------------------------------------------------
    // DELETE /api/v1/3d-models/{id}
    // -------------------------------------------------------------------------
    #[OA\Delete(
        path: '/api/v1/3d-models/{id}',
        summary: '3D modelni o\'chirish',
        tags: ['3D Models'],
        security: [['sanctum' => []]],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [new OA\Response(response: 200, description: 'OK'), new OA\Response(response: 404, description: 'Not Found')]
    )]
    public function destroy(int $id): JsonResponse
    {
        $model = $this->repository->find($id);
        if (! $model) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Topilmadi']], 404);
        }

        $this->repository->delete($id);

        return response()->json(['status' => 'success', 'data' => null], 200);
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------
    private function storeModelFile(Request $request): string|JsonResponse
    {
        $file = $request->file('model_file');
        $ext  = strtolower($file->getClientOriginalExtension());

        if (! in_array($ext, ['glb', 'gltf'], true)) {
            return response()->json(
                ['status' => 'fail', 'data' => ['model_file' => 'Faqat GLB yoki GLTF formatida bo\'lishi kerak.']],
                422
            );
        }

        $filename = Str::uuid() . '.' . $ext;
        return $file->storeAs('3d-models', $filename, 'public');
    }

    private function parseTranslations(Request $request): array
    {
        $raw = $request->input('translations', []);
        if (! is_array($raw)) {
            return [];
        }
        return $raw;
    }
}

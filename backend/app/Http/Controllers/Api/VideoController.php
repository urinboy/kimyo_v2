<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\VideoRepositoryInterface;
use App\Support\VideoApiFormatter;
use App\Support\YouTubeHelper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Videos', description: 'YouTube videolar (admin CRUD, mobil ro\'yxat)')]
class VideoController extends Controller
{
    public function __construct(
        private readonly VideoRepositoryInterface $repository
    ) {}

    #[OA\Get(
        path: '/api/v1/videos',
        summary: 'Videolar ro\'yxati',
        tags: ['Videos'],
        parameters: [
            new OA\Parameter(name: 'lang', in: 'query', required: false, schema: new OA\Schema(type: 'string', example: 'uz')),
        ],
        responses: [new OA\Response(response: 200, description: 'Muvaffaqiyatli')]
    )]
    public function index(Request $request): JsonResponse
    {
        $activeOnly = ! $request->user('sanctum');
        $lang = $request->query('lang');
        $lang = is_string($lang) ? $lang : null;

        $items = $this->repository
            ->all($activeOnly)
            ->map(fn ($v) => $request->user('sanctum')
                ? VideoApiFormatter::adminResource($v)
                : VideoApiFormatter::listItem($v, $lang))
            ->values();

        return response()->json(
            ['status' => 'success', 'data' => ['videos' => $items]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    #[OA\Get(
        path: '/api/v1/videos/{id}',
        summary: 'Bitta video',
        tags: ['Videos'],
        parameters: [new OA\Parameter(name: 'id', in: 'path', required: true, schema: new OA\Schema(type: 'integer'))],
        responses: [
            new OA\Response(response: 200, description: 'Muvaffaqiyatli'),
            new OA\Response(response: 404, description: 'Topilmadi'),
        ]
    )]
    public function show(Request $request, int $id): JsonResponse
    {
        $video = $this->repository->find($id);
        if (! $video) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Video topilmadi']], 404);
        }

        if (! $request->user('sanctum') && ! $video->is_active) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Video topilmadi']], 404);
        }

        $lang = $request->query('lang');
        $lang = is_string($lang) ? $lang : 'uz';

        $payload = $request->user('sanctum')
            ? VideoApiFormatter::adminResource($video)
            : VideoApiFormatter::detail($video, $lang);

        return response()->json(
            ['status' => 'success', 'data' => ['video' => $payload]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    #[OA\Post(path: '/api/v1/videos', summary: 'Yangi video', tags: ['Videos'], responses: [new OA\Response(response: 201, description: 'Yaratildi')])]
    public function store(Request $request): JsonResponse
    {
        $data = $this->validatePayload($request);
        if ($data instanceof JsonResponse) {
            return $data;
        }

        $video = $this->repository->create($data);

        return response()->json(
            ['status' => 'success', 'data' => ['video' => VideoApiFormatter::adminResource($video)]],
            201,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    #[OA\Put(path: '/api/v1/videos/{id}', summary: 'Videoni yangilash', tags: ['Videos'], responses: [new OA\Response(response: 200, description: 'OK')])]
    public function update(Request $request, int $id): JsonResponse
    {
        $data = $this->validatePayload($request, false);
        if ($data instanceof JsonResponse) {
            return $data;
        }

        $video = $this->repository->update($id, $data);
        if (! $video) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Video topilmadi']], 404);
        }

        return response()->json(
            ['status' => 'success', 'data' => ['video' => VideoApiFormatter::adminResource($video)]],
            200,
            [],
            JSON_UNESCAPED_UNICODE
        );
    }

    #[OA\Delete(path: '/api/v1/videos/{id}', summary: 'Videoni o\'chirish', tags: ['Videos'], responses: [new OA\Response(response: 200, description: 'OK')])]
    public function destroy(int $id): JsonResponse
    {
        if (! $this->repository->delete($id)) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Video topilmadi']], 404);
        }

        return response()->json(['status' => 'success', 'data' => null]);
    }

    private function validatePayload(Request $request, bool $requireUrl = true): array|JsonResponse
    {
        $v = Validator::make($request->all(), [
            'youtube_url'                  => ($requireUrl ? 'required' : 'sometimes').'|string|max:512',
            'channel_name'                 => 'nullable|string|max:255',
            'sort_order'                   => 'nullable|integer|min:0',
            'is_active'                    => 'nullable|boolean',
            'translations'                 => ($requireUrl ? 'required' : 'sometimes').'|array|min:1',
            'translations.*.language_code' => 'nullable|string',
            'translations.*.language_id'   => 'nullable|integer',
            'translations.*.title'         => 'required|string|max:500',
            'translations.*.description'   => 'nullable|string',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $validated = $v->validated();
        $urlInput = $validated['youtube_url'] ?? null;

        if ($urlInput !== null) {
            $videoId = YouTubeHelper::extractVideoId($urlInput);
            if (! $videoId) {
                return response()->json([
                    'status' => 'fail',
                    'data'   => ['youtube_url' => ['YouTube havolasi yoki video ID noto\'g\'ri']],
                ], 422);
            }
            $validated['youtube_video_id'] = $videoId;
            $validated['youtube_url'] = YouTubeHelper::canonicalUrl($videoId);
        }

        return $validated;
    }
}

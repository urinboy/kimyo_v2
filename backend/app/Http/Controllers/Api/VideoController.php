<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\VideoRepositoryInterface;
use App\Support\VideoApiFormatter;
use App\Support\YouTubeHelper;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Videos', description: 'YouTube yoki server-hosted videolar')]
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

    #[OA\Post(
        path: '/api/v1/videos',
        summary: 'Yangi video (YouTube URL yoki video fayl)',
        tags: ['Videos'],
        responses: [new OA\Response(response: 201, description: 'Yaratildi')]
    )]
    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'youtube_url'                  => 'nullable|string|max:512',
            'video_file'                   => 'nullable|file|mimes:mp4,webm,avi,mov,mkv|max:524288', // 512 MB
            'channel_name'                 => 'nullable|string|max:255',
            'sort_order'                   => 'nullable|integer|min:0',
            'is_active'                    => 'nullable|boolean',
            'translations'                 => 'required|array|min:1',
            'translations.*.language_code' => 'nullable|string',
            'translations.*.language_id'   => 'nullable|integer',
            'translations.*.title'         => 'required|string|max:500',
            'translations.*.description'   => 'nullable|string',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        // YouTube yoki video fayl — kamida biri bo'lishi kerak
        if (! $request->hasFile('video_file') && ! $request->filled('youtube_url')) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['source' => ['YouTube URL yoki video fayl kerak']],
            ], 422);
        }

        $data = $v->validated();
        $data = $this->resolveVideoSource($request, $data);
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

    #[OA\Post(
        path: '/api/v1/videos/{id}',
        summary: 'Videoni yangilash (multipart yoki JSON)',
        tags: ['Videos'],
        responses: [new OA\Response(response: 200, description: 'OK')]
    )]
    public function update(Request $request, int $id): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'youtube_url'                  => 'nullable|string|max:512',
            'video_file'                   => 'nullable|file|mimes:mp4,webm,avi,mov,mkv|max:524288',
            'remove_video_file'            => 'nullable|boolean',
            'channel_name'                 => 'nullable|string|max:255',
            'sort_order'                   => 'nullable|integer|min:0',
            'is_active'                    => 'nullable|boolean',
            'translations'                 => 'sometimes|array|min:1',
            'translations.*.language_code' => 'nullable|string',
            'translations.*.language_id'   => 'nullable|integer',
            'translations.*.title'         => 'required|string|max:500',
            'translations.*.description'   => 'nullable|string',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $data = $v->validated();

        // Yangi video fayl yuklangan bo'lsa storage ga saqlaymiz
        if ($request->hasFile('video_file')) {
            $path = $this->storeVideoFile($request);
            if ($path instanceof JsonResponse) {
                return $path;
            }
            $data['video_path'] = $path;
        } elseif ($request->boolean('remove_video_file')) {
            $data['video_path'] = null;
        }

        // YouTube URL yangilanayotgan bo'lsa ID ni ajratamiz
        if (isset($data['youtube_url'])) {
            if ($data['youtube_url']) {
                $videoId = YouTubeHelper::extractVideoId($data['youtube_url']);
                if (! $videoId) {
                    return response()->json([
                        'status' => 'fail',
                        'data'   => ['youtube_url' => ['YouTube havolasi noto\'g\'ri']],
                    ], 422);
                }
                $data['youtube_video_id'] = $videoId;
                $data['youtube_url']      = YouTubeHelper::canonicalUrl($videoId);
            } else {
                $data['youtube_video_id'] = null;
                $data['youtube_url']      = null;
            }
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

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private function resolveVideoSource(Request $request, array $data): array|JsonResponse
    {
        if ($request->hasFile('video_file')) {
            $path = $this->storeVideoFile($request);
            if ($path instanceof JsonResponse) {
                return $path;
            }
            $data['video_path'] = $path;
        }

        if (! empty($data['youtube_url'])) {
            $videoId = YouTubeHelper::extractVideoId($data['youtube_url']);
            if (! $videoId) {
                return response()->json([
                    'status' => 'fail',
                    'data'   => ['youtube_url' => ['YouTube havolasi yoki video ID noto\'g\'ri']],
                ], 422);
            }
            $data['youtube_video_id'] = $videoId;
            $data['youtube_url']      = YouTubeHelper::canonicalUrl($videoId);
        }

        return $data;
    }

    private function storeVideoFile(Request $request): string|JsonResponse
    {
        $file = $request->file('video_file');
        if (! $file || ! $file->isValid()) {
            return response()->json([
                'status' => 'fail',
                'data'   => ['video_file' => ['Fayl yuklanmadi yoki buzilgan']],
            ], 422);
        }

        $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
        $path     = $file->storeAs('videos', $filename, 'public');

        return $path; // e.g. "videos/uuid.mp4"
    }
}

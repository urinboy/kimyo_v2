<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Document;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use OpenApi\Attributes as OA;

#[OA\Tag(
    name: 'Documents',
    description: 'Ilova hujjatlari (PDF) — kategoriyalar, ko\'p tilli sarlavhalar, fayl'
)]
class DocumentController extends Controller
{
    private function toResource(Document $d): array
    {
        return [
            'id'                  => $d->id,
            'category'            => $d->category,
            'title_uz'            => $d->title_uz,
            'title_ru'            => $d->title_ru,
            'title_en'            => $d->title_en,
            'file_path'           => $d->file_path,
            'original_filename'   => $d->original_filename,
            'mime_type'           => $d->mime_type,
            'file_size'           => $d->file_size,
            'sort_order'          => $d->sort_order,
            'is_active'           => $d->is_active,
            'file_url'            => $d->file_url,
        ];
    }

    #[OA\Get(
        path: '/api/v1/documents',
        summary: 'Hujjatlar ro\'yxati (mobil + ochiq API)',
        tags: ['Documents'],
        parameters: [
            new OA\Parameter(
                name: 'category',
                in: 'query',
                required: false,
                schema: new OA\Schema(type: 'string', enum: ['decisions', 'laws']),
                description: 'Kategoriya bo\'yicha filtrlash'
            ),
        ],
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
                                new OA\Property(
                                    property: 'documents',
                                    type: 'array',
                                    items: new OA\Items(
                                        type: 'object',
                                        properties: [
                                            new OA\Property(property: 'id', type: 'integer', example: 1),
                                            new OA\Property(property: 'category', type: 'string', example: 'laws'),
                                            new OA\Property(property: 'title_uz', type: 'string', example: 'Namuna'),
                                            new OA\Property(property: 'title_ru', type: 'string', nullable: true),
                                            new OA\Property(property: 'title_en', type: 'string', nullable: true),
                                            new OA\Property(property: 'file_path', type: 'string', example: 'documents/x.pdf'),
                                            new OA\Property(property: 'file_url', type: 'string', example: '/storage/documents/x.pdf'),
                                            new OA\Property(property: 'is_active', type: 'boolean', example: true),
                                            new OA\Property(property: 'sort_order', type: 'integer', example: 0),
                                        ]
                                    )
                                ),
                            ]
                        ),
                    ]
                )
            ),
        ]
    )]
    public function index(Request $request): JsonResponse
    {
        $query = Document::query()->orderBy('category')->orderBy('sort_order')->orderBy('id');

        if (! $request->user('sanctum')) {
            $query->where('is_active', true);
        }

        if ($request->query('category')) {
            $query->where('category', $request->query('category'));
        }

        $items = $query->get()->map(fn (Document $d) => $this->toResource($d));

        return response()->json([
            'status' => 'success',
            'data'   => ['documents' => $items],
        ]);
    }

    public function show(Request $request, Document $document): JsonResponse
    {
        if (! $request->user('sanctum') && ! $document->is_active) {
            return response()->json(['status' => 'fail', 'message' => 'Not found'], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => ['document' => $this->toResource($document)],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'category'         => 'required|in:decisions,laws',
            'title_uz'         => 'required|string|max:500',
            'title_ru'         => 'nullable|string|max:500',
            'title_en'         => 'nullable|string|max:500',
            'file'             => 'required|file|mimes:pdf|max:51200',
            'sort_order'       => 'nullable|integer|min:0',
            'is_active'        => 'nullable|boolean',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $file   = $request->file('file');
        $path   = $file->store('documents', 'public');
        $doc    = new Document;
        $doc->fill([
            'category'            => $v->validated()['category'],
            'title_uz'            => $v->validated()['title_uz'],
            'title_ru'            => $v->validated()['title_ru'] ?? null,
            'title_en'            => $v->validated()['title_en'] ?? null,
            'file_path'           => $path,
            'original_filename'   => $file->getClientOriginalName(),
            'mime_type'           => $file->getMimeType() ?? 'application/pdf',
            'file_size'           => $file->getSize(),
            'sort_order'          => $v->validated()['sort_order'] ?? 0,
            'is_active'           => $v->validated()['is_active'] ?? true,
        ]);
        $doc->save();

        return response()->json([
            'status' => 'success',
            'data'   => ['document' => $this->toResource($doc)],
        ], 201);
    }

    public function update(Request $request, Document $document): JsonResponse
    {
        $v = Validator::make($request->all(), [
            'category'         => 'sometimes|in:decisions,laws',
            'title_uz'         => 'sometimes|string|max:500',
            'title_ru'         => 'nullable|string|max:500',
            'title_en'         => 'nullable|string|max:500',
            'file'             => 'nullable|file|mimes:pdf|max:51200',
            'sort_order'       => 'nullable|integer|min:0',
            'is_active'        => 'nullable|boolean',
        ]);

        if ($v->fails()) {
            return response()->json(['status' => 'fail', 'data' => $v->errors()], 422);
        }

        $data = $v->validated();

        if ($request->hasFile('file')) {
            if ($document->file_path) {
                Storage::disk('public')->delete($document->file_path);
            }
            $file         = $request->file('file');
            $data['file_path'] = $file->store('documents', 'public');
            $data['original_filename'] = $file->getClientOriginalName();
            $data['mime_type'] = $file->getMimeType() ?? 'application/pdf';
            $data['file_size'] = $file->getSize();
        }

        $document->update($data);
        $document->refresh();

        return response()->json([
            'status' => 'success',
            'data'   => ['document' => $this->toResource($document)],
        ]);
    }

    public function destroy(Document $document): JsonResponse
    {
        if ($document->file_path) {
            Storage::disk('public')->delete($document->file_path);
        }
        $document->delete();

        return response()->json([
            'status' => 'success',
            'data'   => null,
        ]);
    }
}

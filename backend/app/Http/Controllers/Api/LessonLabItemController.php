<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Lesson;
use App\Models\LessonLabItem;
use App\Repositories\Interfaces\LessonLabItemRepositoryInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class LessonLabItemController extends Controller
{
    public function __construct(
        private LessonLabItemRepositoryInterface $repository
    ) {}

    public function index(Lesson $lesson): JsonResponse
    {
        return response()->json(
            [
                'status' => 'success',
                'data' => ['items' => $this->repository->allForLesson($lesson->id)],
            ],
            200,
            [],
            JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE
        );
    }

    public function store(Request $request, Lesson $lesson): JsonResponse
    {
        if ($lesson->type !== 'lab') {
            return response()->json([
                'status' => 'fail',
                'message' => 'Lab items can be attached only to laboratory lessons.',
            ], 422);
        }

        $validator = Validator::make($request->all(), $this->rules());
        if ($validator->fails()) {
            return response()->json(['status' => 'fail', 'data' => $validator->errors()], 422);
        }

        $item = $this->repository->create($lesson->id, $this->normalize($validator->validated()));

        return response()->json(['status' => 'success', 'data' => ['item' => $item]], 201);
    }

    public function update(Request $request, LessonLabItem $item): JsonResponse
    {
        $validator = Validator::make($request->all(), $this->rules(false));
        if ($validator->fails()) {
            return response()->json(['status' => 'fail', 'data' => $validator->errors()], 422);
        }

        $updated = $this->repository->update($item->id, $this->normalize($validator->validated()));
        if (! $updated) {
            return response()->json(['status' => 'fail', 'message' => 'Lab item not found'], 404);
        }

        return response()->json(['status' => 'success', 'data' => ['item' => $updated]]);
    }

    public function destroy(LessonLabItem $item): JsonResponse
    {
        $this->repository->delete($item->id);

        return response()->json(['status' => 'success', 'data' => null]);
    }

    /**
     * @return array<string, mixed>
     */
    private function rules(bool $creating = true): array
    {
        $required = $creating ? 'required' : 'sometimes|required';

        return [
            'category' => [$required, Rule::in([
                LessonLabItem::CATEGORY_EQUIPMENT,
                LessonLabItem::CATEGORY_REAGENT,
                LessonLabItem::CATEGORY_ELEMENT,
                LessonLabItem::CATEGORY_VESSEL,
            ])],
            'name' => [$required, 'string', 'max:255'],
            'formula' => ['nullable', 'string', 'max:255'],
            'quantity' => ['nullable', 'string', 'max:80'],
            'unit' => ['nullable', 'string', 'max:32'],
            'notes' => ['nullable', 'string'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
            'is_required' => ['boolean'],
            'is_active' => ['boolean'],
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function normalize(array $data): array
    {
        foreach (['formula', 'quantity', 'unit', 'notes'] as $field) {
            if (array_key_exists($field, $data) && $data[$field] === '') {
                $data[$field] = null;
            }
        }

        return $data;
    }
}

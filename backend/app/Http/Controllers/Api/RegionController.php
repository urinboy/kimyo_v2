<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Language;
use App\Models\Region;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RegionController extends Controller
{
    public function index(): JsonResponse
    {
        $regions = Region::with('translations')->orderBy('id')->get();

        return response()->json([
            'status' => 'success',
            'data'   => ['regions' => $regions->map(fn($r) => $this->format($r))],
        ], 200, [], JSON_UNESCAPED_UNICODE);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'is_active'                => 'boolean',
            'translations'             => 'required|array',
            'translations.*.name'      => 'required|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        $region = Region::create(['is_active' => $request->boolean('is_active', true)]);
        $this->syncTranslations($region, $request->input('translations', []));

        return response()->json([
            'status' => 'success',
            'data'   => ['region' => $this->format($region->load('translations'))],
        ], 201, [], JSON_UNESCAPED_UNICODE);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $region = Region::find($id);
        if (! $region) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Topilmadi']], 404);
        }

        $request->validate([
            'is_active'                => 'boolean',
            'translations'             => 'array',
            'translations.*.name'      => 'required_with:translations|string|max:255',
            'translations.*.description' => 'nullable|string',
        ]);

        $region->update(['is_active' => $request->boolean('is_active', $region->is_active)]);
        if ($request->has('translations')) {
            $this->syncTranslations($region, $request->input('translations', []));
        }

        return response()->json([
            'status' => 'success',
            'data'   => ['region' => $this->format($region->load('translations'))],
        ], 200, [], JSON_UNESCAPED_UNICODE);
    }

    public function destroy(int $id): JsonResponse
    {
        $region = Region::find($id);
        if (! $region) {
            return response()->json(['status' => 'fail', 'data' => ['id' => 'Topilmadi']], 404);
        }

        $region->delete();

        return response()->json(['status' => 'success', 'data' => null]);
    }

    private function syncTranslations(Region $region, array $translations): void
    {
        $langMap = Language::query()->pluck('id', 'id')->all();

        foreach ($translations as $langId => $trans) {
            $langId = (int) $langId;
            if (! isset($langMap[$langId])) {
                continue;
            }
            $region->translations()->updateOrCreate(
                ['language_id' => $langId],
                ['name' => $trans['name'] ?? '', 'description' => $trans['description'] ?? null]
            );
        }
    }

    private function format(Region $region): array
    {
        return [
            'id'           => $region->id,
            'is_active'    => $region->is_active,
            'translations' => $region->translations->map(fn($t) => [
                'language_id' => $t->language_id,
                'name'        => $t->name,
                'description' => $t->description,
            ])->values()->all(),
        ];
    }
}

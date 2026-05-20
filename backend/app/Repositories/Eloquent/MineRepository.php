<?php

namespace App\Repositories\Eloquent;

use App\Models\Mine;
use App\Repositories\Interfaces\MineRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class MineRepository implements MineRepositoryInterface
{
    private Mine $model;

    public function __construct(Mine $model)
    {
        $this->model = $model;
    }

    public function getAll(): Collection
    {
        return $this->model->with(['translations', 'elements'])->get();
    }

    public function findById(int $id): ?Mine
    {
        return $this->model->with(['translations', 'elements'])->find($id);
    }

    public function create(array $data): Mine
    {
        return DB::transaction(function () use ($data) {
            $mine = $this->model->create([
                'latitude' => $data['latitude'],
                'longitude' => $data['longitude'],
                'is_active' => $data['is_active'] ?? true,
                'images' => $data['images'] ?? [],
            ]);

            foreach ($data['translations'] as $langId => $trans) {
                $mine->translations()->create([
                    'language_id' => $langId,
                    'name' => $trans['name'],
                    'description' => $trans['description'] ?? null,
                ]);
            }

            if (isset($data['elements'])) {
                $mine->elements()->sync($data['elements']);
            }

            return $mine->load(['translations', 'elements']);
        });
    }

    public function update(int $id, array $data): ?Mine
    {
        $mine = $this->model->find($id);
        if (!$mine) return null;

        return DB::transaction(function () use ($mine, $data) {
            $mine->update([
                'latitude' => $data['latitude'] ?? $mine->latitude,
                'longitude' => $data['longitude'] ?? $mine->longitude,
                'is_active' => $data['is_active'] ?? $mine->is_active,
                'images' => $data['images'] ?? $mine->images,
            ]);

            if (isset($data['translations'])) {
                foreach ($data['translations'] as $langId => $trans) {
                    $mine->translations()->updateOrCreate(
                        ['language_id' => $langId],
                        ['name' => $trans['name'], 'description' => $trans['description'] ?? null]
                    );
                }
            }

            if (isset($data['elements'])) {
                $mine->elements()->sync($data['elements']);
            }

            return $mine->refresh()->load(['translations', 'elements']);
        });
    }

    public function delete(int $id): bool
    {
        $mine = $this->model->find($id);
        return $mine ? $mine->delete() : false;
    }
}

<?php

namespace App\Repositories\Eloquent;

use App\Models\Formula;
use App\Repositories\Interfaces\FormulaRepositoryInterface;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class FormulaRepository implements FormulaRepositoryInterface
{
    private Formula $model;

    public function __construct(Formula $model)
    {
        $this->model = $model;
    }

    public function getAll(): Collection
    {
        return $this->model->with(['translations', 'elements'])->get();
    }

    public function findById(int $id): ?Formula
    {
        return $this->model->with(['translations', 'elements'])->find($id);
    }

    public function create(array $data): Formula
    {
        return DB::transaction(function () use ($data) {
            $formula = $this->model->create([
                'formula' => $data['formula'],
                'molar_mass' => $data['molar_mass'] ?? null,
                'category' => $data['category'] ?? null,
            ]);

            foreach ($data['translations'] as $langId => $trans) {
                $formula->translations()->create([
                    'language_id' => $langId,
                    'name' => $trans['name'],
                ]);
            }

            if (isset($data['elements']) && is_array($data['elements'])) {
                foreach ($data['elements'] as $element) {
                    $formula->elements()->attach($element['element_id'], ['amount' => $element['amount']]);
                }
            }

            return $formula->load(['translations', 'elements']);
        });
    }

    public function update(int $id, array $data): ?Formula
    {
        $formula = $this->model->find($id);
        if (!$formula) return null;

        return DB::transaction(function () use ($formula, $data) {
            $formula->update([
                'formula' => $data['formula'] ?? $formula->formula,
                'molar_mass' => $data['molar_mass'] ?? $formula->molar_mass,
                'category' => $data['category'] ?? $formula->category,
            ]);

            if (isset($data['translations'])) {
                foreach ($data['translations'] as $langId => $trans) {
                    $formula->translations()->updateOrCreate(
                        ['language_id' => $langId],
                        ['name' => $trans['name']]
                    );
                }
            }

            if (isset($data['elements']) && is_array($data['elements'])) {
                $syncData = [];
                foreach ($data['elements'] as $element) {
                    $syncData[$element['element_id']] = ['amount' => $element['amount']];
                }
                $formula->elements()->sync($syncData);
            }

            return $formula->refresh()->load(['translations', 'elements']);
        });
    }

    public function delete(int $id): bool
    {
        $formula = $this->model->find($id);
        return $formula ? $formula->delete() : false;
    }
}

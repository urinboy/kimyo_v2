<?php

namespace App\Repositories\Eloquent;

use App\Models\Element;
use App\Models\ElementTranslation;
use App\Repositories\Interfaces\ElementRepositoryInterface;
use Illuminate\Support\Facades\DB;

class ElementRepository implements ElementRepositoryInterface
{
    public function all()
    {
        return Element::with('translations.language')->get();
    }

    public function find(int $id)
    {
        return Element::with('translations.language')->find($id);
    }

    public function create(array $data)
    {
        return DB::transaction(function () use ($data) {
            $element = Element::create([
                'atomic_number' => $data['atomic_number'],
                'symbol'        => $data['symbol'],
                'mass'          => $data['mass'],
                'color_hex'     => $data['color_hex'] ?? null,
                'type'          => $data['type'] ?? 'metal',
            ]);

            if (isset($data['translations']) && is_array($data['translations'])) {
                foreach ($data['translations'] as $translation) {
                    $element->translations()->create([
                        'language_id' => $translation['language_id'],
                        'name'        => $translation['name'],
                        'description' => $translation['description'] ?? null,
                    ]);
                }
            }

            return $element->load('translations.language');
        });
    }

    public function update(int $id, array $data)
    {
        return DB::transaction(function () use ($id, $data) {
            $element = Element::find($id);
            if (!$element) return null;

            $element->update([
                'atomic_number' => $data['atomic_number'] ?? $element->atomic_number,
                'symbol'        => $data['symbol'] ?? $element->symbol,
                'mass'          => $data['mass'] ?? $element->mass,
                'color_hex'     => $data['color_hex'] ?? $element->color_hex,
                'type'          => $data['type'] ?? $element->type,
            ]);

            if (isset($data['translations']) && is_array($data['translations'])) {
                // For simplicity, we'll update or create. 
                // In a production app, we might want to be more granular.
                foreach ($data['translations'] as $translation) {
                    $element->translations()->updateOrCreate(
                        ['language_id' => $translation['language_id']],
                        [
                            'name'        => $translation['name'],
                            'description' => $translation['description'] ?? null,
                        ]
                    );
                }
            }

            return $element->load('translations.language');
        });
    }

    public function delete(int $id)
    {
        $element = Element::find($id);
        if ($element) {
            // Translations will be deleted via cascade
            return $element->delete();
        }
        return false;
    }
}

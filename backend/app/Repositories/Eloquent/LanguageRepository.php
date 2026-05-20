<?php

namespace App\Repositories\Eloquent;

use App\Models\Language;
use App\Repositories\Interfaces\LanguageRepositoryInterface;

class LanguageRepository implements LanguageRepositoryInterface
{
    public function all()
    {
        return Language::all();
    }

    public function find(int $id)
    {
        return Language::find($id);
    }

    public function create(array $data)
    {
        return Language::create($data);
    }

    public function update(int $id, array $data)
    {
        $language = Language::find($id);
        if ($language) {
            $language->update($data);
            return $language;
        }
        return null;
    }

    public function delete(int $id)
    {
        $language = Language::find($id);
        if ($language) {
            return $language->delete();
        }
        return false;
    }
}

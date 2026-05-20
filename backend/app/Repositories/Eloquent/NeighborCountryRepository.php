<?php

namespace App\Repositories\Eloquent;

use App\Models\NeighborCountry;
use App\Repositories\Interfaces\NeighborCountryRepositoryInterface;

class NeighborCountryRepository implements NeighborCountryRepositoryInterface
{
    public function all()
    {
        return NeighborCountry::orderBy('sort_order')->get();
    }

    public function find(int $id)
    {
        return NeighborCountry::find($id);
    }

    public function create(array $data)
    {
        return NeighborCountry::create($data);
    }

    public function update(int $id, array $data)
    {
        $country = NeighborCountry::find($id);
        if (!$country) return null;
        
        $country->update($data);
        return $country;
    }

    public function delete(int $id)
    {
        $country = NeighborCountry::find($id);
        if ($country) {
            return $country->delete();
        }
        return false;
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\NeighborCountryRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class NeighborCountryController extends Controller
{
    protected $repository;

    public function __construct(NeighborCountryRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index()
    {
        $countries = $this->repository->all();
        return response()->json([
            'status' => 'success',
            'data' => [
                'countries' => $countries
            ]
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'code'              => 'required|string|max:10|unique:neighbor_countries',
            'name_uz'           => 'required|string|max:255',
            'name_ru'           => 'nullable|string|max:255',
            'name_en'           => 'nullable|string|max:255',
            'capital_uz'        => 'nullable|string|max:255',
            'capital_ru'        => 'nullable|string|max:255',
            'capital_en'        => 'nullable|string|max:255',
            'description_uz'    => 'nullable|string',
            'description_ru'    => 'nullable|string',
            'description_en'    => 'nullable|string',
            'area_km2'          => 'nullable|numeric',
            'population_mn'     => 'nullable|numeric',
            'languages_uz'      => 'nullable|string',
            'languages_ru'      => 'nullable|string',
            'languages_en'      => 'nullable|string',
            'currency_uz'       => 'nullable|string',
            'currency_ru'       => 'nullable|string',
            'currency_en'       => 'nullable|string',
            'border_with_uz_km' => 'nullable|numeric',
            'flag_emoji'        => 'nullable|string|max:10',
            'sort_order'        => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $country = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'country' => $country
            ]
        ], 201);
    }

    public function show($id)
    {
        $country = $this->repository->find($id);

        if (!$country) {
            return response()->json([
                'status' => 'error',
                'message' => 'Country not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'country' => $country
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'code'              => 'sometimes|string|max:10|unique:neighbor_countries,code,' . $id,
            'name_uz'           => 'sometimes|string|max:255',
            'sort_order'        => 'nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $country = $this->repository->update($id, $request->all());

        if (!$country) {
            return response()->json([
                'status' => 'error',
                'message' => 'Country not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'country' => $country
            ]
        ]);
    }

    public function destroy($id)
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'Country not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

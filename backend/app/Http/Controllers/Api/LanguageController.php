<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\LanguageRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LanguageController extends Controller
{
    protected $repository;

    public function __construct(LanguageRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index()
    {
        $languages = $this->repository->all();
        return response()->json([
            'status' => 'success',
            'data' => [
                'languages' => $languages
            ]
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'code' => 'required|string|unique:languages,code|max:10',
            'name' => 'required|string|max:100',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $language = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'language' => $language
            ]
        ], 201);
    }

    public function show($id)
    {
        $language = $this->repository->find($id);

        if (!$language) {
            return response()->json([
                'status' => 'error',
                'message' => 'Language not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'language' => $language
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'code' => 'sometimes|string|max:10|unique:languages,code,' . $id,
            'name' => 'sometimes|string|max:100',
            'is_active' => 'boolean'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $language = $this->repository->update($id, $request->all());

        if (!$language) {
            return response()->json([
                'status' => 'error',
                'message' => 'Language not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'language' => $language
            ]
        ]);
    }

    public function destroy($id)
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'Language not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

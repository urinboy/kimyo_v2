<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\GeographyTopicRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class GeographyTopicController extends Controller
{
    protected $repository;

    public function __construct(GeographyTopicRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function index(Request $request)
    {
        $category = $request->query('category');
        $topics = $this->repository->all($category);
        
        return response()->json([
            'status' => 'success',
            'data' => [
                'topics' => $topics
            ]
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category'   => 'required|string|max:50',
            'parent_id'  => 'nullable|exists:geography_topics,id',
            'icon'       => 'nullable|string|max:50',
            'sort_order' => 'nullable|integer',
            'is_active'  => 'nullable|boolean',
            'translations' => 'required|array|min:1',
            'translations.*.language_id' => 'required|exists:languages,id',
            'translations.*.title'       => 'required|string|max:255',
            'translations.*.content'     => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $topic = $this->repository->create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'topic' => $topic
            ]
        ], 201);
    }

    public function show($id)
    {
        $topic = $this->repository->find($id);

        if (!$topic) {
            return response()->json([
                'status' => 'error',
                'message' => 'Topic not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'topic' => $topic
            ]
        ]);
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'category'   => 'sometimes|string|max:50',
            'parent_id'  => 'nullable|exists:geography_topics,id',
            'icon'       => 'nullable|string|max:50',
            'sort_order' => 'nullable|integer',
            'is_active'  => 'nullable|boolean',
            'translations' => 'sometimes|array',
            'translations.*.language_id' => 'required_with:translations|exists:languages,id',
            'translations.*.title'       => 'required_with:translations|string|max:255',
            'translations.*.content'     => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $topic = $this->repository->update($id, $request->all());

        if (!$topic) {
            return response()->json([
                'status' => 'error',
                'message' => 'Topic not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'topic' => $topic
            ]
        ]);
    }

    public function destroy($id)
    {
        $deleted = $this->repository->delete($id);

        if (!$deleted) {
            return response()->json([
                'status' => 'error',
                'message' => 'Topic not found'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 204);
    }
}

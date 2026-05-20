<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AuthorAdditionalInfo;
use Illuminate\Http\Request;

class AuthorAdditionalInfoController extends Controller
{
    public function index()
    {
        $infos = AuthorAdditionalInfo::orderBy('order')->get();
        return response()->json([
            'status' => 'success',
            'data' => [
                'additional_infos' => $infos
            ]
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'key_uz' => 'required|string',
            'value_uz' => 'required|string',
        ]);

        $info = AuthorAdditionalInfo::create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'additional_info' => $info
            ]
        ], 201);
    }

    public function update(Request $request, AuthorAdditionalInfo $additional_info)
    {
        $additional_info->update($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'additional_info' => $additional_info
            ]
        ]);
    }

    public function destroy(AuthorAdditionalInfo $additional_info)
    {
        $additional_info->delete();
        return response()->json([
            'status' => 'success',
            'message' => 'Additional info deleted successfully'
        ]);
    }
}

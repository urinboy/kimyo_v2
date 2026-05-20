<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AuthorExperience;
use Illuminate\Http\Request;

class AuthorExperienceController extends Controller
{
    public function index()
    {
        $experiences = AuthorExperience::orderBy('order')->get();
        return response()->json([
            'status' => 'success',
            'data' => [
                'experiences' => $experiences
            ]
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'years' => 'required|string',
            'description_uz' => 'required|string',
        ]);

        $experience = AuthorExperience::create($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'experience' => $experience
            ]
        ], 201);
    }

    public function update(Request $request, AuthorExperience $experience)
    {
        $experience->update($request->all());

        return response()->json([
            'status' => 'success',
            'data' => [
                'experience' => $experience
            ]
        ]);
    }

    public function destroy(AuthorExperience $experience)
    {
        $experience->delete();
        return response()->json([
            'status' => 'success',
            'message' => 'Experience deleted successfully'
        ]);
    }
}

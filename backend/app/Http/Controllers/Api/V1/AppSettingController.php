<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppSetting;
use Illuminate\Http\Request;

class AppSettingController extends Controller
{
    public function index()
    {
        $settings = AppSetting::first();
        return response()->json([
            'status' => 'success',
            'data' => [
                'settings' => $settings
            ]
        ]);
    }

    public function update(Request $request)
    {
        $settings = AppSetting::first();
        if (! $settings) {
            $settings = new AppSetting();
        }

        $fillable = (new AppSetting())->getFillable();
        $data = $request->only($fillable);

        if ($request->hasFile('author_image')) {
            $data['author_image'] = $request->file('author_image')->store('authors', 'public');
        } elseif ($request->has('author_image') && is_string($request->input('author_image'))) {
            $data['author_image'] = $request->string('author_image');
        } else {
            unset($data['author_image']);
        }

        $settings->fill($data);
        $settings->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Settings updated successfully',
            'data' => [
                'settings' => $settings
            ]
        ]);
    }
}

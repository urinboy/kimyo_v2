<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index()
    {
        $reviews = Review::with('user')->latest()->get();
        $total = Review::count();
        $average = $total > 0 ? round((float) Review::avg('rating'), 1) : 0.0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'reviews' => $reviews,
                'summary' => [
                    'average_rating' => $average,
                    'total_reviews' => $total,
                ],
            ],
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        $review = Review::create([
            'user_id' => auth()->id(),
            'rating' => $request->rating,
            'comment' => $request->comment,
            'device_info' => $request->header('User-Agent'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Review submitted successfully',
            'data' => [
                'review' => $review
            ]
        ], 201);
    }

    public function destroy(Review $review)
    {
        $review->delete();
        return response()->json([
            'status' => 'success',
            'message' => 'Review deleted successfully'
        ]);
    }
}

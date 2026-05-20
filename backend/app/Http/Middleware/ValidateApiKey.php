<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ValidateApiKey
{
    public function handle(Request $request, Closure $next): Response
    {
        $configuredKey = config('app.mobile_api_key');

        // Agar .env da kalit sozlanmagan bo'lsa — xavfsizlik uchun o'tkazib yubormaymiz
        if (empty($configuredKey)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'API key is not configured on server.',
            ], 500);
        }

        $providedKey = $request->header('X-API-Key');

        if (empty($providedKey) || !hash_equals($configuredKey, $providedKey)) {
            return response()->json([
                'status'  => 'fail',
                'data'    => ['message' => 'API key yaroqsiz yoki ko\'rsatilmagan.'],
            ], 401);
        }

        return $next($request);
    }
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Laravel\Sanctum\PersonalAccessToken;
use Symfony\Component\HttpFoundation\Response;

/**
 * auth:sanctum majburiy bo‘lmagan marshrutlarda Bearer token bo‘lsa foydalanuvchini bog‘laydi
 * (admin panel GET /interesting-tasks kabi).
 */
class AttachSanctumUserFromBearerIfPresent
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() !== null) {
            return $next($request);
        }

        $plain = $request->bearerToken();
        if ($plain === null || $plain === '') {
            return $next($request);
        }

        $pat = PersonalAccessToken::findToken($plain);
        if ($pat && $pat->tokenable) {
            $request->setUserResolver(static fn () => $pat->tokenable);
        }

        return $next($request);
    }
}

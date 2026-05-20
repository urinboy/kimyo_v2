<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * php artisan serve ba'zan katta JSON javoblarni output buffer sababli kesadi.
 */
class ClearOutputBuffers
{
    public function handle(Request $request, Closure $next): Response
    {
        while (ob_get_level() > 0) {
            ob_end_clean();
        }

        return $next($request);
    }
}

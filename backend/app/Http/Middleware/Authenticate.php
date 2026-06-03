<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * API-only backend: hech qachon 'login' named route ga redirect qilinmaydi.
     * null qaytarish redirectTo() ichida route('login') chaqirilishini oldini oladi,
     * shunda AuthenticationException toza tarzda exception renderer ga yetib boradi (401 JSON).
     */
    protected function redirectTo(Request $request): ?string
    {
        return null;
    }
}

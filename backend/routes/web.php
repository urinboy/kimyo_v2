<?php

use Illuminate\Support\Facades\Route;

Route::get('/api', function () {
    return redirect('/api/documentation');
});

Route::view('/', 'admin');

Route::fallback(function () {
    if (! in_array(request()->method(), ['GET', 'HEAD'], true)) {
        abort(404);
    }

    return view('admin');
});

<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return auth()->check() ? redirect()->route('contacts.index') : redirect()->route('login');
});

use App\Http\Controllers\ContactController;

Route::middleware(['auth'])->group(function () {
    Route::resource('contacts', ContactController::class);
});

<?php

use App\Http\Controllers\ContactController;

Route::middleware(['auth'])->group(function () {
    Route::resource('contacts', ContactController::class);
});

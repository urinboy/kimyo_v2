<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('option_translations', function (Blueprint $col) {
            $col->id();
            $col->foreignId('option_id')->constrained('options')->onDelete('cascade');
            $col->foreignId('language_id')->constrained('languages')->onDelete('cascade');
            $col->string('text');
            $col->timestamps();

            $col->unique(['option_id', 'language_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('option_translations');
    }
};

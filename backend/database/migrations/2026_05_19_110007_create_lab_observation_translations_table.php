<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_observation_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_observation_id')->constrained()->cascadeOnDelete();
            $table->foreignId('language_id')->constrained()->cascadeOnDelete();
            $table->text('text');
            $table->timestamps();

            $table->unique(['lab_observation_id', 'language_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_observation_translations');
    }
};

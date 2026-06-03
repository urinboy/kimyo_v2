<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('regions', function (Blueprint $table) {
            $table->id();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('region_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('region_id')->constrained('regions')->cascadeOnDelete();
            $table->foreignId('language_id')->constrained('languages')->cascadeOnDelete();
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->timestamps();

            $table->unique(['region_id', 'language_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('region_translations');
        Schema::dropIfExists('regions');
    }
};

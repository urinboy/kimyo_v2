<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('three_d_model_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('three_d_model_id')
                ->constrained('three_d_models')
                ->cascadeOnDelete();
            $table->foreignId('language_id')
                ->constrained('languages')
                ->cascadeOnDelete();
            $table->string('name', 255);
            $table->text('description')->nullable();
            $table->timestamps();

            $table->unique(['three_d_model_id', 'language_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('three_d_model_translations');
    }
};

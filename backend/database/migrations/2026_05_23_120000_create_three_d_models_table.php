<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('three_d_models', function (Blueprint $table) {
            $table->id();
            $table->string('slug', 100)->unique();          // "iron_ore", "magnetite" — identifikator
            $table->string('model_path', 512)->nullable();  // storage/app/public/3d-models/uuid.glb
            $table->foreignId('element_id')
                ->nullable()
                ->constrained('elements')
                ->nullOnDelete();
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('three_d_models');
    }
};

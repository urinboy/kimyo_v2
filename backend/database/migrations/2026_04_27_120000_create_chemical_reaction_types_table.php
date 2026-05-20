<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chemical_reaction_types', function (Blueprint $table) {
            $table->id();
            $table->string('name_uz');
            $table->string('name_ru')->nullable();
            $table->string('name_en')->nullable();
            $table->string('name_kaa')->nullable();
            $table->string('formula');
            /** Yorug‘ fon uchun (Flutter `color`) */
            $table->string('color_hex', 6);
            $table->string('icon_color_hex', 6);
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chemical_reaction_types');
    }
};

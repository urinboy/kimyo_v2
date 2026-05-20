<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('chemical_reaction_symbols', function (Blueprint $table) {
            $table->id();
            $table->string('symbol', 16);
            $table->string('desc_uz');
            $table->string('desc_ru')->nullable();
            $table->string('desc_en')->nullable();
            $table->string('desc_kaa')->nullable();
            $table->unsignedInteger('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('chemical_reaction_symbols');
    }
};

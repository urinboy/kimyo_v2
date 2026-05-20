<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_product_translations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_product_id')->constrained()->cascadeOnDelete();
            $table->foreignId('language_id')->constrained()->cascadeOnDelete();
            $table->string('name')->comment('Masalan: Mis(II)-nitrat, Kumush metalli');
            $table->timestamps();

            $table->unique(['lab_product_id', 'language_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_product_translations');
    }
};

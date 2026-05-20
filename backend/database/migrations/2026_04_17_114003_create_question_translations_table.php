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
        Schema::create('question_translations', function (Blueprint $col) {
            $col->id();
            $col->foreignId('question_id')->constrained()->onDelete('cascade');
            $col->foreignId('language_id')->constrained()->onDelete('cascade');
            $col->text('text');
            $col->string('image_url')->nullable();
            $col->timestamps();

            $col->unique(['question_id', 'language_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('question_translations');
    }
};

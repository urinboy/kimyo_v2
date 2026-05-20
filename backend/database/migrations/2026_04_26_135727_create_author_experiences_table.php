<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('author_experiences', function (Blueprint $table) {
            $table->id();
            $table->string('years'); // masalan: 2006-2015
            $table->string('description_uz');
            $table->string('description_ru')->nullable();
            $table->string('description_en')->nullable();
            $table->integer('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('author_experiences');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('documents', function (Blueprint $table) {
            $table->id();
            $table->string('category', 32)->index();
            $table->string('title_uz', 500);
            $table->string('title_ru', 500)->nullable();
            $table->string('title_en', 500)->nullable();
            $table->string('file_path', 500);
            $table->string('original_filename', 500)->nullable();
            $table->string('mime_type', 120)->default('application/pdf');
            $table->unsignedBigInteger('file_size')->default(0);
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('documents');
    }
};

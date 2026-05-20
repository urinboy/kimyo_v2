<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('author_additional_infos', function (Blueprint $table) {
            $table->id();
            $table->string('key_uz');
            $table->string('key_ru')->nullable();
            $table->string('key_en')->nullable();
            $table->string('value_uz');
            $table->string('value_ru')->nullable();
            $table->string('value_en')->nullable();
            $table->integer('order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('author_additional_infos');
    }
};

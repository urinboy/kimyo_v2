<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_works', function (Blueprint $table) {
            $table->id();
            $table->tinyInteger('number')->unsigned()->comment('Laboratoriya raqami (6, 8, 10...)');
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_works');
    }
};

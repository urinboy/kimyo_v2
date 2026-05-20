<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_experiments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_work_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['probirka', 'tajriba', 'bosqich'])->default('probirka');
            $table->tinyInteger('order_index')->unsigned()->default(1);
            $table->enum('status', ['active', 'inactive'])->default('active');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_experiments');
    }
};

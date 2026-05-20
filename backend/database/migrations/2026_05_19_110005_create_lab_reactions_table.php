<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_reactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_experiment_id')->constrained()->cascadeOnDelete();
            $table->text('formula')->comment('Kimyoviy tenglama (plain text)');
            $table->enum('type', ['molecular', 'full_ionic', 'short_ionic'])->default('molecular');
            $table->tinyInteger('order_index')->unsigned()->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_reactions');
    }
};

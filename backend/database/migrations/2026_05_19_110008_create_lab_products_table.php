<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('lab_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_experiment_id')->constrained()->cascadeOnDelete();
            $table->string('chemical_formula', 100)->comment('Masalan: Cu(NO3)2, Ag');
            $table->enum('state', ['dissolved', 'precipitate', 'gas', 'solid', 'unknown'])
                  ->default('dissolved')
                  ->comment('dissolved=erigan, precipitate=cho\'kma, gas=gaz, solid=qattiq');
            $table->tinyInteger('order_index')->unsigned()->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('lab_products');
    }
};

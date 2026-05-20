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
        Schema::create('elements', function (Blueprint $table) {
            $table->id();
            $table->integer('atomic_number')->unique();
            $table->string('symbol', 10)->unique();
            $table->decimal('mass', 10, 4);
            $table->string('color_hex', 7)->nullable();
            $table->string('type')->default('metal'); // metal, nonmetal, etc.
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('elements');
    }
};

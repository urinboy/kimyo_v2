<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('neighbor_countries', function (Blueprint $table) {
            $table->id();
            $table->string('code', 2)->unique();
            $table->unsignedTinyInteger('sort_order')->default(0);
            $table->string('name_uz', 100);
            $table->string('name_ru', 100);
            $table->string('name_en', 100);
            $table->string('capital_uz', 100);
            $table->string('capital_ru', 100);
            $table->string('capital_en', 100);
            $table->text('description_uz');
            $table->text('description_ru');
            $table->text('description_en');
            $table->unsignedBigInteger('area_km2');
            $table->decimal('population_mn', 6, 1);
            $table->string('languages_uz', 200);
            $table->string('languages_ru', 200);
            $table->string('languages_en', 200);
            $table->string('currency_uz', 50);
            $table->string('currency_ru', 50);
            $table->string('currency_en', 50);
            $table->unsignedInteger('border_with_uz_km');
            $table->string('flag_emoji', 20)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('neighbor_countries');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('chemical_reaction_types', function (Blueprint $table) {
            $table->text('description_uz')->nullable()->after('formula');
            $table->text('description_ru')->nullable();
            $table->text('description_en')->nullable();
            $table->text('description_kaa')->nullable();
            /** Modalda binafsha qutidagi formula (null bo'lsa, badge ko'rsatiladi). */
            $table->text('modal_formula')->nullable();
            $table->string('modal_badge_uz', 255)->nullable();
            $table->string('modal_badge_ru', 255)->nullable();
            $table->string('modal_badge_en', 255)->nullable();
            $table->string('modal_badge_kaa', 255)->nullable();
            /** @var array<int, string> */
            $table->json('examples')->nullable();
        });
    }

    public function down(): void
    {
        Schema::table('chemical_reaction_types', function (Blueprint $table) {
            $table->dropColumn([
                'description_uz',
                'description_ru',
                'description_en',
                'description_kaa',
                'modal_formula',
                'modal_badge_uz',
                'modal_badge_ru',
                'modal_badge_en',
                'modal_badge_kaa',
                'examples',
            ]);
        });
    }
};

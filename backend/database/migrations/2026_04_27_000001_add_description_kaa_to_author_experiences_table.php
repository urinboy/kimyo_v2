<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('author_experiences', function (Blueprint $table) {
            $table->string('description_kaa')->nullable()->after('description_en');
        });
    }

    public function down(): void
    {
        Schema::table('author_experiences', function (Blueprint $table) {
            $table->dropColumn('description_kaa');
        });
    }
};

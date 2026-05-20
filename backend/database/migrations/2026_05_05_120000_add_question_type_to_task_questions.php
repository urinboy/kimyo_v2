<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('task_questions', function (Blueprint $table) {
            $table->string('question_type', 16)->default('text')->after('body');
            $table->string('image_path')->nullable()->after('question_type');
            $table->json('match_data')->nullable()->after('image_path');
        });
    }

    public function down(): void
    {
        Schema::table('task_questions', function (Blueprint $table) {
            $table->dropColumn(['question_type', 'image_path', 'match_data']);
        });
    }
};

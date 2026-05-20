<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('task_answers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('submission_id')->constrained('task_submissions')->cascadeOnDelete();
            $table->foreignId('question_id')->constrained('task_questions')->cascadeOnDelete();
            $table->text('answer_text');
            $table->boolean('is_correct')->nullable();
            $table->unsignedTinyInteger('score')->default(0);
            $table->text('teacher_comment')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('task_answers');
    }
};

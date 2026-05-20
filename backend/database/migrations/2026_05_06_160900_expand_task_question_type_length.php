<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE `task_questions` MODIFY `question_type` VARCHAR(64) NOT NULL DEFAULT 'text'");
            return;
        }

        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE task_questions ALTER COLUMN question_type TYPE VARCHAR(64)");
            DB::statement("ALTER TABLE task_questions ALTER COLUMN question_type SET DEFAULT 'text'");
            return;
        }

        // SQLite: VARCHAR length is not enforced the same way; schema already sufficient.
    }

    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if ($driver === 'mysql') {
            DB::statement("ALTER TABLE `task_questions` MODIFY `question_type` VARCHAR(16) NOT NULL DEFAULT 'text'");
            return;
        }

        if ($driver === 'pgsql') {
            DB::statement("ALTER TABLE task_questions ALTER COLUMN question_type TYPE VARCHAR(16)");
            DB::statement("ALTER TABLE task_questions ALTER COLUMN question_type SET DEFAULT 'text'");
            return;
        }
    }
};


<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('interesting_tasks', 'task_kind')) {
            return;
        }

        Schema::table('interesting_tasks', function (Blueprint $table) {
            $table->string('task_kind', 32)->default('interesting')->after('sort_order');
        });
    }

    public function down(): void
    {
        if (! Schema::hasColumn('interesting_tasks', 'task_kind')) {
            return;
        }

        Schema::table('interesting_tasks', function (Blueprint $table) {
            $table->dropColumn('task_kind');
        });
    }
};

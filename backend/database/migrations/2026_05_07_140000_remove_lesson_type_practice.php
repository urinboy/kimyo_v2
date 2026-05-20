<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('lessons')) {
            return;
        }

        DB::table('lessons')->where('type', 'practice')->delete();

        $driver = Schema::getConnection()->getDriverName();
        if (in_array($driver, ['mysql', 'mariadb'], true)) {
            DB::statement("ALTER TABLE lessons MODIFY COLUMN type ENUM('theory', 'lab') NOT NULL DEFAULT 'theory'");
        }
        // SQLite: `enum` is stored as string; practice rows removed above.
    }

    public function down(): void
    {
        if (! Schema::hasTable('lessons')) {
            return;
        }

        $driver = Schema::getConnection()->getDriverName();
        if (in_array($driver, ['mysql', 'mariadb'], true)) {
            DB::statement("ALTER TABLE lessons MODIFY COLUMN type ENUM('theory', 'practice', 'lab') NOT NULL DEFAULT 'theory'");
        }
    }
};

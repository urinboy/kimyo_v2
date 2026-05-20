<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->string('type')->default('chemistry')->after('category'); // chemistry | geography
            $table->string('title_uz')->nullable()->after('type');
            $table->string('title_ru')->nullable()->after('title_uz');
            $table->string('title_en')->nullable()->after('title_ru');
            $table->unsignedInteger('sort_order')->default(0)->after('is_active');
        });

        if (Schema::hasTable('quizzes')) {
            $rows = DB::table('quizzes')->whereNull('lesson_id')->orderBy('id')->get();
            $i = 0;
            foreach ($rows as $row) {
                $patch = [
                    'type' => 'chemistry',
                    'sort_order' => $i * 10,
                ];
                if ((string) $row->category === 'elements') {
                    $patch['title_uz'] = 'Kimyoviy elementlar';
                    $patch['title_ru'] = 'Химические элементы';
                    $patch['title_en'] = 'Chemical elements';
                } elseif ((string) $row->category === 'periodic_table') {
                    $patch['title_uz'] = 'Davriy jadval';
                    $patch['title_ru'] = 'Периодическая таблица';
                    $patch['title_en'] = 'Periodic table';
                }
                DB::table('quizzes')->where('id', $row->id)->update($patch);
                $i++;
            }
        }
    }

    public function down(): void
    {
        Schema::table('quizzes', function (Blueprint $table) {
            $table->dropColumn(['type', 'title_uz', 'title_ru', 'title_en', 'sort_order']);
        });
    }
};

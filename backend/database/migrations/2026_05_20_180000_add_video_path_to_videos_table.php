<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('videos', function (Blueprint $table) {
            // Server-hosted video fayli uchun path (nullable — YouTube yoki server, kamida biri kerak)
            $table->string('video_path', 512)->nullable()->after('youtube_url');

            // Serverga yuklangan videolar YouTube ID siz ham bo'lishi mumkin
            $table->string('youtube_video_id', 32)->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('videos', function (Blueprint $table) {
            $table->dropColumn('video_path');
            $table->string('youtube_video_id', 32)->nullable(false)->change();
        });
    }
};

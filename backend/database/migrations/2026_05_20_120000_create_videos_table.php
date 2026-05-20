<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('videos', function (Blueprint $table) {
            $table->id();
            $table->string('youtube_video_id', 32);
            $table->string('youtube_url', 512)->nullable();
            $table->string('channel_name', 255)->nullable();
            $table->unsignedInteger('sort_order')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique('youtube_video_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('videos');
    }
};

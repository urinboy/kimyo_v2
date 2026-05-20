<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('app_version')->default('v2.5.13');
            $table->integer('app_version_code')->default(26);
            
            // Author info
            $table->string('author_name')->nullable();
            $table->string('author_role')->nullable();
            $table->string('author_image')->nullable();
            $table->string('author_birth_date')->nullable();
            $table->string('author_birth_place')->nullable();
            $table->string('author_nationality')->nullable();
            $table->string('author_education')->nullable();
            $table->string('author_specialization')->nullable();
            $table->string('author_languages')->nullable();
            $table->string('author_work_position')->nullable();
            $table->string('author_work_organization')->nullable();
            
            // App info
            $table->text('about_app_uz')->nullable();
            $table->text('about_app_ru')->nullable();
            $table->text('about_app_en')->nullable();
            $table->string('privacy_policy_url')->nullable();
            $table->string('terms_url')->nullable();
            
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_settings');
    }
};

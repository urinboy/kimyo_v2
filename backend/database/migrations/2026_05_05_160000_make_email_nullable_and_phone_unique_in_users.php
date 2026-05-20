<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // email may now be null for phone-only registered users
            $table->string('email')->nullable()->change();
            // add unique constraint on phone (ignore nulls — MySQL allows multiple NULLs)
            $table->string('phone')->nullable()->unique()->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('email')->nullable(false)->change();
            $table->string('phone')->nullable()->change(); // remove unique
        });
    }
};

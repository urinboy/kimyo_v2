<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class LanguageSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('languages')->insert([
            ['code' => 'uz', 'name' => 'Oʻzbekcha', 'is_active' => true],
            ['code' => 'ru', 'name' => 'Русский', 'is_active' => true],
            ['code' => 'en', 'name' => 'English', 'is_active' => true],
            ['code' => 'kaa', 'name' => 'Qaraqalpaqsha', 'is_active' => true],
        ]);
    }
}

<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call([
            LanguageSeeder::class,
            RolesAndPermissionsSeeder::class,
            AdminSeeder::class,
            StudentUserSeeder::class,
            ManualUsersSeeder::class,
            LessonSeeder::class,
            LessonLabItemSeeder::class,
            ElementSeeder::class,
            FormulaSeeder::class,
            QuizSeeder::class,
            ChemistryTopicsQuizSeeder::class,
            ChemistryTopicsTheorySeeder::class,
            GeographyPoliticalMapSeeder::class,
            GeographyContinentsSeeder::class,
            GeographyCapitalsSeeder::class,
            GeographyClimateWeatherSeeder::class,
            GeographyRocksSeeder::class,
            GeographyMineralsSeeder::class,
            GeographyReliefSeeder::class,
            GeographyPhenomenaSeeder::class,
            AppSettingSeeder::class,
            ChemicalReactionSeeder::class,
            NeighborCountrySeeder::class,
            InterestingTasksPdfContentSeeder::class,
            LessonProjectsSeeder::class,
            DocumentSeeder::class,
            LabWorkSeeder::class,
            VideoSeeder::class,
        ]);
    }
}

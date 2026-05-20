<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(
            \App\Repositories\Interfaces\LanguageRepositoryInterface::class,
            \App\Repositories\Eloquent\LanguageRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\ElementRepositoryInterface::class,
            \App\Repositories\Eloquent\ElementRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\MineRepositoryInterface::class,
            \App\Repositories\Eloquent\MineRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\AuthRepositoryInterface::class,
            \App\Repositories\Eloquent\AuthRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\UserRepositoryInterface::class,
            \App\Repositories\Eloquent\UserRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\RoleRepositoryInterface::class,
            \App\Repositories\Eloquent\RoleRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\LessonRepositoryInterface::class,
            \App\Repositories\Eloquent\LessonRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\LessonLabItemRepositoryInterface::class,
            \App\Repositories\Eloquent\LessonLabItemRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\FormulaRepositoryInterface::class,
            \App\Repositories\Eloquent\FormulaRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\QuizRepositoryInterface::class,
            \App\Repositories\Eloquent\EloquentQuizRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\MobileAuthRepositoryInterface::class,
            \App\Repositories\Eloquent\MobileAuthRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\GeographyTopicRepositoryInterface::class,
            \App\Repositories\Eloquent\GeographyTopicRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\NeighborCountryRepositoryInterface::class,
            \App\Repositories\Eloquent\NeighborCountryRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\SchoolRepositoryInterface::class,
            \App\Repositories\Eloquent\SchoolRepository::class
        );

        $this->app->bind(
            \App\Repositories\Interfaces\LabWorkRepositoryInterface::class,
            \App\Repositories\Eloquent\LabWorkRepository::class
        );
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}

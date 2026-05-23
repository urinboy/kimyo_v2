<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\InterestingTaskController;
use App\Http\Controllers\Api\LanguageController;
use App\Http\Controllers\Api\ElementController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\PermissionController;
use App\Http\Controllers\Api\SchoolController;
use App\Http\Controllers\Api\MineController;
use App\Http\Controllers\Api\LessonController;
use App\Http\Controllers\Api\LessonLabItemController;
use App\Http\Controllers\Api\FormulaController;
use App\Http\Controllers\Api\ChemicalReactionController;
use App\Http\Controllers\Api\ChemicalReactionTypeController;
use App\Http\Controllers\Api\ChemicalReactionSymbolController;
use App\Http\Controllers\Api\StandaloneQuizController;
use App\Http\Controllers\Api\QuizAttemptController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\MobileAuthController;
use App\Http\Controllers\Api\MobileReferenceController;
use App\Http\Controllers\Api\MobileReviewController;
use App\Http\Controllers\Api\V1\AppSettingController;
use App\Http\Controllers\Api\V1\ReviewController;
use App\Http\Controllers\Api\V1\AuthorExperienceController;
use App\Http\Controllers\Api\V1\AuthorAdditionalInfoController;
use App\Http\Controllers\Api\V1\DocumentController;
use App\Http\Controllers\Api\LabWorkController;
use App\Http\Controllers\Api\VideoController;
use App\Http\Controllers\Api\ThreeDModelController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/**
 * API kalitisiz — faqat ruxsat etilgan public-disk yo‘llari.
 * Flutter web /storage ga to‘g‘ridan-to‘g‘ri murojaatda CORS bo‘lmaydi; shu marshrut cors.php (api/*) orqali yopiladi.
 */
Route::prefix('v1')->group(function () {
    // {path} ichida '/' bo‘lishi kerak (masalan task-questions/5/fayl.jpg) — oddiy `.+` bitta segment bilan cheklanadi.
    Route::get('public-storage/{path}', [InterestingTaskController::class, 'publicStorageFile'])
        ->where('path', '.*');
});

Route::prefix('v1')->middleware('api.key')->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    })->middleware('auth:sanctum');

    Route::prefix('auth')->group(function () {
        Route::post('/login', [AuthController::class, 'login']);
        
        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/logout', [AuthController::class, 'logout']);
            Route::get('/me', [AuthController::class, 'me']);
        });
    });

    // Mobile Auth routes
    Route::prefix('mobile/auth')->group(function () {
        Route::post('/register', [MobileAuthController::class, 'register']);
        Route::post('/login',    [MobileAuthController::class, 'login']);

        Route::middleware('auth:sanctum')->group(function () {
            Route::post('/logout', [MobileAuthController::class, 'logout']);
            Route::get('/me',      [MobileAuthController::class, 'me']);
            Route::put('/profile', [MobileAuthController::class, 'updateProfile']);
            Route::put('/password', [MobileAuthController::class, 'changePassword']);
        });
    });

    // Mobile Reviews (summary — ochiq; yuborish — Bearer bo‘lsa user_id bog‘lanadi)
    Route::get('mobile/reviews/summary', [MobileReviewController::class, 'summary']);
    Route::middleware(['sanctum.bearer', 'auth:sanctum'])->get(
        'mobile/reviews/me',
        [MobileReviewController::class, 'myReview']
    );
    Route::post('mobile/reviews', [MobileReviewController::class, 'store'])
        ->middleware('sanctum.bearer');

    Route::get('mobile/reference/schools', [MobileReferenceController::class, 'schools']);
    Route::get('mobile/reference/grades', [MobileReferenceController::class, 'grades']);
    Route::middleware(['sanctum.bearer', 'auth:sanctum'])->group(function () {
        Route::post('mobile/reference/schools', [MobileReferenceController::class, 'storeSchool']);
        Route::post('mobile/reference/grades', [MobileReferenceController::class, 'storeGrade']);
    });

    // Public routes
    Route::get('elements', [ElementController::class, 'index']);
    Route::get('elements/{element}', [ElementController::class, 'show']);
    Route::get('lessons', [LessonController::class, 'index']);
    Route::get('lessons/{lesson}', [LessonController::class, 'show']);
    Route::get('mines', [MineController::class, 'index']);
    Route::get('mines/{mine}', [MineController::class, 'show']);
    Route::get('formulas', [FormulaController::class, 'index']);
    Route::get('formulas/{formula}', [FormulaController::class, 'show']);
    Route::get('chemical-reactions', [ChemicalReactionController::class, 'index']);
    Route::get('lessons/{lesson}/lab-items', [LessonLabItemController::class, 'index']);
    Route::get('standalone-quizzes', [StandaloneQuizController::class, 'index']);
    Route::get('standalone-quizzes/{id}', [StandaloneQuizController::class, 'show'])->whereNumber('id');
    Route::get('settings', [AppSettingController::class, 'index']);
    Route::get('author/experience', [AuthorExperienceController::class, 'index']);
    Route::get('author/additional-info', [AuthorAdditionalInfoController::class, 'index']);

    Route::get('documents', [DocumentController::class, 'index']);
    Route::get('documents/{document}', [DocumentController::class, 'show']);

    // Lab Works — GET ochiq (mobil va veb uchun)
    Route::get('lab-works', [LabWorkController::class, 'index']);
    Route::get('lab-works/{id}', [LabWorkController::class, 'show'])->whereNumber('id');

    // Videolar (YouTube) — GET ochiq
    Route::get('videos', [VideoController::class, 'index']);
    Route::get('videos/{id}', [VideoController::class, 'show'])->whereNumber('id');

    // 3D modellar — GET ochiq (mobil uchun)
    Route::get('3d-models', [ThreeDModelController::class, 'index']);
    Route::get('3d-models/{id}', [ThreeDModelController::class, 'show'])->whereNumber('id');

    // Interesting tasks — GET ro‘yxat / bitta mavzu (token bo‘lsa admin: barchasi, token yo‘q: faqat faol)
    Route::middleware('sanctum.bearer')->group(function () {
        Route::get('interesting-tasks', [InterestingTaskController::class, 'listTasks']);
        Route::get('interesting-tasks/{id}', [InterestingTaskController::class, 'showTask'])->whereNumber('id');
    });
    Route::middleware(['sanctum.bearer', 'auth:sanctum'])->post(
        'interesting-tasks/{id}/submit',
        [InterestingTaskController::class, 'submit']
    )->whereNumber('id');

    Route::middleware(['sanctum.bearer', 'auth:sanctum'])->post(
        'standalone-quizzes/{id}/attempts',
        [QuizAttemptController::class, 'store']
    )->whereNumber('id');

    Route::get('neighbor-countries', [\App\Http\Controllers\Api\NeighborCountryController::class, 'index']);
    Route::get('neighbor-countries/{id}', [\App\Http\Controllers\Api\NeighborCountryController::class, 'show']);
    Route::get('geography-topics', [\App\Http\Controllers\Api\GeographyTopicController::class, 'index']);
    Route::get('geography-topics/{id}', [\App\Http\Controllers\Api\GeographyTopicController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function () {
        Route::apiResource('languages', LanguageController::class);
        Route::apiResource('elements', ElementController::class)->except(['index', 'show']);
        Route::apiResource('users', UserController::class);
        Route::apiResource('roles', RoleController::class);
        Route::apiResource('permissions', PermissionController::class)->only(['index', 'store', 'update', 'destroy']);
        Route::get('schools/{id}/assignable-users', [SchoolController::class, 'assignableUsers'])->whereNumber('id');
        Route::post('schools/{id}/students/attach', [SchoolController::class, 'attachStudents'])->whereNumber('id');
        Route::post('schools/{id}/students/detach', [SchoolController::class, 'detachStudents'])->whereNumber('id');
        Route::get('schools/{id}/students', [SchoolController::class, 'students'])->whereNumber('id');
        Route::apiResource('schools', SchoolController::class);
        Route::apiResource('mines', MineController::class)->except(['index', 'show']);
        Route::apiResource('lessons', LessonController::class)->except(['index', 'show']);
        Route::get('lessons/{lesson}/lab-items', [LessonLabItemController::class, 'index']);
        Route::post('lessons/{lesson}/lab-items', [LessonLabItemController::class, 'store']);
        Route::put('lesson-lab-items/{item}', [LessonLabItemController::class, 'update']);
        Route::delete('lesson-lab-items/{item}', [LessonLabItemController::class, 'destroy']);
        Route::apiResource('formulas', FormulaController::class)->except(['index', 'show']);
        
        // App Settings & Reviews
        Route::post('settings', [AppSettingController::class, 'update']);
        Route::apiResource('author/experience', AuthorExperienceController::class)->except(['index']);
        Route::apiResource('author/additional-info', AuthorAdditionalInfoController::class)->except(['index']);
        Route::apiResource('reviews', ReviewController::class)->only(['index', 'destroy']);
        Route::post('reviews', [ReviewController::class, 'store']); // Allow authenticated users to store
        
        // Lab Works (laboratoriya ishlari) — POST/PUT/DELETE faqat admin
        Route::post('lab-works', [LabWorkController::class, 'store']);
        Route::put('lab-works/{id}', [LabWorkController::class, 'update'])->whereNumber('id');
        Route::delete('lab-works/{id}', [LabWorkController::class, 'destroy'])->whereNumber('id');

        Route::post('videos', [VideoController::class, 'store']);
        Route::post('videos/{id}', [VideoController::class, 'update'])->whereNumber('id'); // multipart + _method=PUT
        Route::put('videos/{id}', [VideoController::class, 'update'])->whereNumber('id');
        Route::delete('videos/{id}', [VideoController::class, 'destroy'])->whereNumber('id');

        // 3D modellar — CUD faqat admin
        Route::post('3d-models', [ThreeDModelController::class, 'store']);
        Route::post('3d-models/{id}', [ThreeDModelController::class, 'update'])->whereNumber('id'); // multipart workaround
        Route::put('3d-models/{id}', [ThreeDModelController::class, 'update'])->whereNumber('id');
        Route::delete('3d-models/{id}', [ThreeDModelController::class, 'destroy'])->whereNumber('id');

        // Dashboard
        Route::get('dashboard/stats', [DashboardController::class, 'stats']);
        Route::get('dashboard/activity', [DashboardController::class, 'activity']);
        Route::get('dashboard/student-results', [DashboardController::class, 'studentResults']);
        Route::get('dashboard/research-stats', [DashboardController::class, 'researchStats']);
        
        // Quizzes
        Route::get('lessons/{lesson}/quiz', [\App\Http\Controllers\Api\QuizController::class, 'showByLesson']);
        Route::post('quizzes/{quiz}/sync', [\App\Http\Controllers\Api\QuizController::class, 'syncQuestions']);
        Route::apiResource('quizzes', \App\Http\Controllers\Api\QuizController::class)->except(['index']);

        Route::apiResource('chemical-reaction-types', ChemicalReactionTypeController::class)->only(['store', 'update', 'destroy']);
        Route::apiResource('chemical-reaction-symbols', ChemicalReactionSymbolController::class)->only(['store', 'update', 'destroy']);

        Route::post('standalone-quizzes', [StandaloneQuizController::class, 'store']);
        Route::put('standalone-quizzes/{id}', [StandaloneQuizController::class, 'update'])->whereNumber('id');
        Route::delete('standalone-quizzes/{id}', [StandaloneQuizController::class, 'destroy'])->whereNumber('id');
        Route::get('standalone-quizzes/{id}/attempts-report', [QuizAttemptController::class, 'adminReport'])->whereNumber('id');

        Route::post('documents', [DocumentController::class, 'store']);
        /** PDF yangilash: brauzer multipart + PUT ba'zida fayl kelmay qoladi — POST qabul qilamiz */
        Route::post('documents/{document}', [DocumentController::class, 'update']);
        Route::put('documents/{document}', [DocumentController::class, 'update']);
        Route::delete('documents/{document}', [DocumentController::class, 'destroy']);

        // Geography routes
        Route::apiResource('neighbor-countries', \App\Http\Controllers\Api\NeighborCountryController::class);
        Route::apiResource('geography-topics', \App\Http\Controllers\Api\GeographyTopicController::class);

        // Interesting tasks — admin CRUD
        Route::apiResource('interesting-tasks', InterestingTaskController::class)->except(['index', 'show']);
        Route::post('interesting-tasks/{taskId}/questions', [InterestingTaskController::class, 'storeQuestion'])->whereNumber('taskId');
        /** Multipart (rasm) + PUT: fayl/maydonlar kelmay qolishi mumkin — POST ham qabul */
        Route::post('interesting-tasks/{taskId}/questions/{questionId}', [InterestingTaskController::class, 'updateQuestion'])->whereNumber('taskId', 'questionId');
        Route::put('interesting-tasks/{taskId}/questions/{questionId}', [InterestingTaskController::class, 'updateQuestion'])->whereNumber('taskId', 'questionId');
        Route::delete('interesting-tasks/{taskId}/questions/{questionId}', [InterestingTaskController::class, 'destroyQuestion'])->whereNumber('taskId', 'questionId');

        // Submissions — admin
        Route::get('task-submissions', [InterestingTaskController::class, 'submissions']);
        Route::patch('task-submissions/visibility-bulk', [InterestingTaskController::class, 'bulkUpdateSubmissionVisibility']);
        Route::patch('task-submissions/reset-bulk', [InterestingTaskController::class, 'bulkResetSubmissions']);
        Route::delete('task-submissions/bulk', [InterestingTaskController::class, 'bulkDestroySubmissions']);
        Route::get('task-submissions/{id}', [InterestingTaskController::class, 'submissionDetail'])->whereNumber('id');
        Route::put('task-submissions/{id}/check', [InterestingTaskController::class, 'checkSubmission'])->whereNumber('id');
        Route::patch('task-submissions/{id}/visibility', [InterestingTaskController::class, 'updateSubmissionVisibility'])->whereNumber('id');
        Route::patch('task-submissions/{id}/reset', [InterestingTaskController::class, 'resetSubmission'])->whereNumber('id');
        Route::delete('task-submissions/{id}', [InterestingTaskController::class, 'destroySubmission'])->whereNumber('id');

        // My submissions — mobile auth
        Route::get('my-submissions', [InterestingTaskController::class, 'mySubmissions']);
        Route::get('my-submissions/{id}', [InterestingTaskController::class, 'mySubmissionDetail'])->whereNumber('id');
    });
});

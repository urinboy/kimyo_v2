<?php

namespace App\Http\Controllers;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: "2.5.13",
    title: "Kimyo v2 API Documentation",
    description: "9-sinf o'quvchilari uchun interaktiv kimyo platformasi API hujjatlari",
    contact: new OA\Contact(email: "admin@kimyo.uz")
)]
#[OA\Server(
    url: "http://localhost:8000",
    description: "Asosiy API Server"
)]
#[OA\SecurityScheme(
    securityScheme: "bearerAuth",
    type: "http",
    name: "Token",
    in: "header",
    bearerFormat: "JWT",
    scheme: "bearer",
    description: "Sanctum Bearer Token orqali autentifikatsiya"
)]
abstract class Controller
{
    //
}

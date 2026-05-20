<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Repositories\Interfaces\AuthRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    protected AuthRepositoryInterface $authRepository;

    public function __construct(AuthRepositoryInterface $authRepository)
    {
        $this->authRepository = $authRepository;
    }

    /**
     * Login user and return JSend response.
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'login' => 'required|string',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'fail',
                'data' => $validator->errors()
            ], 400);
        }

        $result = $this->authRepository->login($request->only('login', 'password'));

        if (!$result) {
            return response()->json([
                'status' => 'fail',
                'data' => ['message' => 'Invalid credentials']
            ], 401);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $result['user'],
                'token' => $result['token']
            ]
        ], 200);
    }

    /**
     * Logout user and return JSend response.
     */
    public function logout(Request $request)
    {
        $this->authRepository->logout();

        return response()->json([
            'status' => 'success',
            'data' => null
        ], 200);
    }

    /**
     * Get me details and return JSend response.
     */
    public function me(Request $request)
    {
        $user = $this->authRepository->getMe();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $user
            ]
        ], 200);
    }
}

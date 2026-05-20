<?php

namespace App\Repositories\Interfaces;

interface GeographyTopicRepositoryInterface
{
    public function all(string $category = null);
    public function find(int $id);
    public function create(array $data);
    public function update(int $id, array $data);
    public function delete(int $id);
}

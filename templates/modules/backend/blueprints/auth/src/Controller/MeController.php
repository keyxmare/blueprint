<?php
namespace App\Controller\Auth;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;

final class MeController
{
    public function __construct(private TokenStorageInterface $tokens) {}

    #[Route('/api/me', name: 'api_me', methods: ['GET'])]
    #[IsGranted('IS_AUTHENTICATED_FULLY')]
    public function __invoke(): JsonResponse
    {
        $user = $this->tokens->getToken()?->getUser();
        return new JsonResponse(['email' => method_exists($user, 'getEmail') ? $user->getEmail() : null]);
    }
}

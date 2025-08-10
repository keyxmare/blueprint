<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    public function testTrivial(): void
    {
        self::assertSame(2, 1+1);
    }
}

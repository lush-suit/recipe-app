<?php
declare(strict_types=1);
function e(string $s): string { return htmlspecialchars($s, ENT_QUOTES, 'UTF-8'); }
function base_url(string $p=''): string { $cfg=require __DIR__.'/../config.php'; $b=rtrim($cfg['app']['base_url'],'/'); return $b.($p?'/public/'.$p:''); }

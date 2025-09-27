<?php
declare(strict_types=1);
function csrf_token(): string { if (empty($_SESSION['csrf'])) $_SESSION['csrf']=bin2hex(random_bytes(32)); return $_SESSION['csrf']; }
function csrf_field(): string { return '<input type="hidden" name="csrf" value="'.htmlspecialchars(csrf_token(),ENT_QUOTES,'UTF-8').'">'; }
function verify_csrf(): void { if ($_SERVER['REQUEST_METHOD']==='POST') { $t=$_POST['csrf']??''; if (!hash_equals($_SESSION['csrf']??'', $t)) { http_response_code(400); echo 'Invalid CSRF token.'; exit; } } }

<?php
declare(strict_types=1);
function start_secure_session(): void {
  if (session_status() !== PHP_SESSION_ACTIVE) {
    /* Harden cookie security: allow forcing Secure even behind proxies */
$forceSecure = getenv('FORCE_SECURE_COOKIES') ? true : false;
session_set_cookie_params(['secure' => ($forceSecure || !empty($_SERVER['HTTPS'])), 'httponly'=>true, 'samesite'=>'Lax']);
    session_start();
    if (!isset($_SESSION['initiated'])) { session_regenerate_id(true); $_SESSION['initiated']=true; }
  }
}
function current_user_id(): ?int { return $_SESSION['user_id'] ?? null; }
function require_login(): void { if (!current_user_id()) { header('Location: login.php'); exit; } }
function login($pdo, string $email, string $password): bool {
  $st=$pdo->prepare('SELECT id,password_hash FROM users WHERE email=?'); $st->execute([$email]); $u=$st->fetch();
  if ($u && password_verify($password, $u['password_hash'])) { $_SESSION['user_id']=(int)$u['id']; return true; } return false;
}
function logout(): void { $_SESSION=[]; if (ini_get('session.use_cookies')) { $p=session_get_cookie_params();
  setcookie(session_name(),' ',time()-42000,$p['path'],$p['domain'],$p['secure'],$p['httponly']); } session_destroy(); }

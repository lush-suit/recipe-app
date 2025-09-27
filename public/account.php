<?php
require_once __DIR__ . '/../app/includes/auth.php'; require_once __DIR__ . '/../app/includes/utils.php'; require_once __DIR__ . '/../app/includes/db.php';
require_login(); require_once __DIR__ . '/../app/templates/header.php';
$st=$pdo->prepare('SELECT name,email,created_at FROM users WHERE id=?'); $st->execute([current_user_id()]); $u=$st->fetch();
?><h1>Your Account</h1><div class="card"><p><strong>Name:</strong> <?= e($u['name'])?></p><p><strong>Email:</strong> <?= e($u['email'])?></p><p><strong>Member since:</strong> <?= e($u['created_at'])?></p></div>
<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>

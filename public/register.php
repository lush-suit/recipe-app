<?php
require_once __DIR__ . '/../app/includes/auth.php'; require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/csrf.php'; require_once __DIR__ . '/../app/includes/db.php'; start_secure_session();
$errors=[]; if($_SERVER['REQUEST_METHOD']==='POST'){ verify_csrf();
  $name=trim($_POST['name']??''); $email=trim($_POST['email']??''); $password=$_POST['password']??''; $confirm=$_POST['confirm_password']??'';
$pwPattern = '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{10,}$/';
if (!preg_match($pwPattern, $password)) { $errors[] = 'Password must be ≥10 chars and include upper, lower, number, and symbol.'; }
  if ($name===''||$email===''||$password==='') $errors[]='All required fields must be filled.';
  if (!filter_var($email,FILTER_VALIDATE_EMAIL)) $errors[]='Invalid email.';
  if ($password!==$confirm) $errors[]='Passwords do not match.';
  if (strlen($password)<8) $errors[]='Password must be at least 8 characters.';
  if (!$errors){ $st=$pdo->prepare('SELECT id FROM users WHERE email=?'); $st->execute([$email]);
    if($st->fetch()) $errors[]='Email already registered.';
    else { $hash=password_hash($password,PASSWORD_DEFAULT);
      $pdo->prepare('INSERT INTO users(name,email,password_hash) VALUES (?,?,?)')->execute([$name,$email,$hash]);
      $_SESSION['user_id']=(int)$pdo->lastInsertId(); header('Location: index.php'); exit;
    }
  }
}
require_once __DIR__ . '/../app/templates/header.php'; ?>
<h1>Create your account</h1>
<?php if($errors): ?><div class="card" role="alert"><ul><?php foreach($errors as $e) echo '<li>'.e($e).'</li>'; ?></ul></div><?php endif; ?>
<form method="post" class="card needs-validate" novalidate>
  <?= csrf_field() ?>
  <label for="name">Name*</label>
<small id="pw-help">10+ chars, upper, lower, number, and a symbol</small><input id="name" name="name" required>
  <label for="email">Email*</label><input id="email" name="email" type="email" required>
  <label for="password">Password*</label><input id="password" name="password" type="password" minlength="10" pattern="(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{10,}" aria-describedby="pw-help" required>
  <label for="confirm_password">Confirm Password*</label><input id="confirm_password" name="confirm_password" type="password" required>
  <button type="submit">Register</button>
</form>
<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>

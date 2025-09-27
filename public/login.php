<?php
global $pdo;
require_once __DIR__ . '/../app/includes/auth.php';
require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/csrf.php';
require_once __DIR__ . '/../app/includes/db.php';
require_once __DIR__ . '/../app/includes/cache.php';
require_once __DIR__ . '/../app/includes/error_handler.php';

start_secure_session();

$errors = [];
$email = '';

// Rate limiting
$rateLimitKey = 'login_attempts_' . ($_SERVER['REMOTE_ADDR'] ?? 'unknown');
$cache = getCache();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        verify_csrf();
        
        // Check rate limiting
        $attempts = $cache->get($rateLimitKey, 0);
        if ($attempts >= 5) {
            $errors[] = 'Too many login attempts. Please try again in 15 minutes.';
        } else {
            // Validate input
            $validation = validateInput([
                'email' => [
                    'required' => true,
                    'type' => 'email',
                    'label' => 'Email',
                    'max_length' => 255
                ],
                'password' => [
                    'required' => true,
                    'type' => 'string',
                    'label' => 'Password',
                    'min_length' => 1,
                    'max_length' => 255
                ]
            ], $_POST);
            
            if (!empty($validation['errors'])) {
                $errors = array_values($validation['errors']);
            } else {
                $email = $validation['data']['email'];
                $password = $validation['data']['password'];
                
                if (!login($pdo, $email, $password)) {
                    $errors[] = 'Invalid email or password.';
                    
                    // Increment failed attempts
                    $cache->set($rateLimitKey, $attempts + 1, 900); // 15 minutes
                    
                    // Log failed login attempt
                    logError('Failed login attempt', [
                        'email' => $email,
                        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
                        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown'
                    ]);
                } else {
                    // Clear failed attempts on successful login
                    $cache->delete($rateLimitKey);
                    
                    // Log successful login
                    logError('Successful login', [
                        'email' => $email,
                        'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown'
                    ]);
                    
                    header('Location: index.php');
                    exit;
                }
            }
        }
    } catch (Exception $e) {
        logError('Login error', ['error' => $e->getMessage()]);
        $errors[] = 'An error occurred during login. Please try again.';
    }
}

require_once __DIR__ . '/../app/templates/header.php';
?>
<h1>Login</h1>
<?php if ($errors): ?>
    <div class="card" role="alert">
        <ul>
            <?php foreach ($errors as $error): ?>
                <li><?= e($error) ?></li>
            <?php endforeach; ?>
        </ul>
    </div>
<?php endif; ?>

<form method="post" class="card needs-validate" novalidate>
    <?= csrf_field() ?>
    <label for="email">Email*</label>
    <input id="email" name="email" type="email" value="<?= e($email) ?>" required maxlength="255">
    
    <label for="password">Password*</label>
    <input id="password" name="password" type="password" required>
    
    <button type="submit">Login</button>
</form>

<div class="card">
    <p>Don't have an account? <a href="register.php">Create one here</a></p>
    <p><small>Demo account: demo@example.com / Password123!</small></p>
</div>

<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>

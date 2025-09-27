
<?php
declare(strict_types=1);

/**
 * Comprehensive error handling system for Recipe Web App
 */

// Set up error logging
ini_set('log_errors', "1");
ini_set('error_log', __DIR__ . '/../../logs/php_errors.log');

// Create logs directory if it doesn't exist
$logDir = __DIR__ . '/../../logs';
if (!is_dir($logDir)) {
    mkdir($logDir, 0755, true);
}

/**
 * Custom error handler
 */
function customErrorHandler($severity, $message, $file, $line): bool {
    // Don't handle suppressed errors (@)
    if (!(error_reporting() & $severity)) {
        return false;
    }
    
    $errorTypes = [
        E_ERROR => 'Fatal Error',
        E_WARNING => 'Warning',
        E_PARSE => 'Parse Error',
        E_NOTICE => 'Notice',
        E_CORE_ERROR => 'Core Error',
        E_CORE_WARNING => 'Core Warning',
        E_COMPILE_ERROR => 'Compile Error',
        E_COMPILE_WARNING => 'Compile Warning',
        E_USER_ERROR => 'User Error',
        E_USER_WARNING => 'User Warning',
        E_USER_NOTICE => 'User Notice',
        E_STRICT => 'Strict Notice',
        E_RECOVERABLE_ERROR => 'Recoverable Error'
    ];
    
    $errorType = $errorTypes[$severity] ?? 'Unknown Error';
    $logMessage = sprintf(
        "[%s] %s: %s in %s on line %d",
        date('Y-m-d H:i:s'),
        $errorType,
        $message,
        $file,
        $line
    );
    
    error_log($logMessage);
    
    // For fatal errors, show user-friendly message
    if ($severity & (E_ERROR | E_CORE_ERROR | E_COMPILE_ERROR | E_USER_ERROR)) {
        showErrorPage('A system error occurred. Please try again later.');
    }
    
    return true;
}

/**
 * Custom exception handler
 */
function customExceptionHandler(Throwable $exception): void {
    $logMessage = sprintf(
        "[%s] Uncaught %s: %s in %s:%d\nStack trace:\n%s",
        date('Y-m-d H:i:s'),
        get_class($exception),
        $exception->getMessage(),
        $exception->getFile(),
        $exception->getLine(),
        $exception->getTraceAsString()
    );
    
    error_log($logMessage);
    
    // Show user-friendly error page
    showErrorPage('An unexpected error occurred. Please try again later.');
}

/**
 * Show user-friendly error page
 */
function showErrorPage(string $message): void {
    if (!headers_sent()) {
        http_response_code(500);
        header('Content-Type: text/html; charset=utf-8');
    }
    
    echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Error - Recipe Web App</title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 2rem; text-align: center; }
        .error-container { max-width: 600px; margin: 0 auto; }
        .error-icon { font-size: 4rem; color: #dc2626; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">⚠️</div>
        <h1>Oops! Something went wrong</h1>
        <p>' . htmlspecialchars($message, ENT_QUOTES, 'UTF-8') . '</p>
        <p><a href="/">← Return to Home</a></p>
    </div>
</body>
</html>';
    exit;
}

/**
 * Log application-specific errors
 */
function logError(string $message, array $context = []): void {
    $logMessage = sprintf(
        "[%s] APP_ERROR: %s",
        date('Y-m-d H:i:s'),
        $message
    );
    
    if (!empty($context)) {
        $logMessage .= ' Context: ' . json_encode($context);
    }
    
    error_log($logMessage);
}

/**
 * Handle database errors gracefully
 * @throws Exception
 */
function handleDatabaseError(PDOException $e, string $operation = 'database operation'): void {
    logError("Database error during $operation", [
        'error' => $e->getMessage(),
        'code' => $e->getCode(),
        'file' => $e->getFile(),
        'line' => $e->getLine()
    ]);
    
    // Don't expose database details to users
    throw new Exception("Unable to complete $operation. Please try again later.");
}

/**
 * Validate and sanitize input
 */
function validateInput(array $rules, array $data): array {
    $errors = [];
    $sanitized = [];
    
    foreach ($rules as $field => $rule) {
        $value = $data[$field] ?? null;
        
        // Required check
        if (isset($rule['required']) && $rule['required'] && empty($value)) {
            $errors[$field] = $rule['label'] . ' is required.';
            continue;
        }
        
        // Skip validation if field is optional and empty
        if (empty($value) && !isset($rule['required'])) {
            $sanitized[$field] = '';
            continue;
        }
        
        // Type validation
        switch ($rule['type'] ?? 'string') {
            case 'email':
                if (!filter_var($value, FILTER_VALIDATE_EMAIL)) {
                    $errors[$field] = 'Invalid email format.';
                } else {
                    $sanitized[$field] = filter_var($value, FILTER_SANITIZE_EMAIL);
                }
                break;
                
            case 'int':
                if (!filter_var($value, FILTER_VALIDATE_INT)) {
                    $errors[$field] = $rule['label'] . ' must be a valid number.';
                } else {
                    $sanitized[$field] = (int)$value;
                }
                break;
                
            case 'float':
                if (!filter_var($value, FILTER_VALIDATE_FLOAT)) {
                    $errors[$field] = $rule['label'] . ' must be a valid number.';
                } else {
                    $sanitized[$field] = (float)$value;
                }
                break;
                
            case 'string':
            default:
                $sanitized[$field] = trim($value);
                
                // Length validation
                if (isset($rule['min_length']) && strlen($sanitized[$field]) < $rule['min_length']) {
                    $errors[$field] = $rule['label'] . ' must be at least ' . $rule['min_length'] . ' characters.';
                }
                
                if (isset($rule['max_length']) && strlen($sanitized[$field]) > $rule['max_length']) {
                    $errors[$field] = $rule['label'] . ' cannot exceed ' . $rule['max_length'] . ' characters.';
                }
                
                // Pattern validation
                if (isset($rule['pattern']) && !preg_match($rule['pattern'], $sanitized[$field])) {
                    $errors[$field] = $rule['pattern_message'] ?? $rule['label'] . ' format is invalid.';
                }
                break;
        }
        
        // Range validation for numbers
        if (in_array($rule['type'] ?? 'string', ['int', 'float'])) {
            if (isset($rule['min']) && $sanitized[$field] < $rule['min']) {
                $errors[$field] = $rule['label'] . ' must be at least ' . $rule['min'] . '.';
            }
            
            if (isset($rule['max']) && $sanitized[$field] > $rule['max']) {
                $errors[$field] = $rule['label'] . ' cannot exceed ' . $rule['max'] . '.';
            }
        }
    }
    
    return ['errors' => $errors, 'data' => $sanitized];
}

// Set custom error and exception handlers
set_error_handler('customErrorHandler');
set_exception_handler('customExceptionHandler');

// Handle fatal errors
register_shutdown_function(function() {
    $error = error_get_last();
    if ($error && in_array($error['type'], [E_ERROR, E_CORE_ERROR, E_COMPILE_ERROR, E_USER_ERROR])) {
        customErrorHandler($error['type'], $error['message'], $error['file'], $error['line']);
    }
});


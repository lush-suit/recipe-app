<?php
declare(strict_types=1);

require_once __DIR__ . '/error_handler.php';

$config = require __DIR__ . '/../config.php';

try {
    $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=%s',
        $config['db']['host'],
        $config['db']['port'],
        $config['db']['name'],
        $config['db']['charset']
    );
    
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
        PDO::ATTR_PERSISTENT => true,
        PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci"
    ];
    
    $pdo = new PDO($dsn, $config['db']['user'], $config['db']['pass'], $options);
    
    // Test the connection
    $pdo->query('SELECT 1');
    
} catch (PDOException $e) {
    logError('Database connection failed', [
        'host' => $config['db']['host'],
        'database' => $config['db']['name'],
        'error' => $e->getMessage()
    ]);
    
    showErrorPage('Database connection failed. Please try again later.');
}

/**
 * Execute query with comprehensive error handling
 */
function executeQuery(PDO $pdo, string $query, array $params = []): PDOStatement {
    try {
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        return $stmt;
    } catch (PDOException $e) {
        handleDatabaseError($e, 'query execution');
        throw $e; // Re-throw for proper handling
    }
}

/**
 * Fetch single row with error handling
 */
function fetchOne(PDO $pdo, string $query, array $params = []): ?array {
    try {
        $stmt = executeQuery($pdo, $query, $params);
        $result = $stmt->fetch();
        return $result ?: null;
    } catch (Exception $e) {
        logError('Error fetching single row', ['query' => $query, 'error' => $e->getMessage()]);
        return null;
    }
}

/**
 * Fetch multiple rows with error handling
 */
function fetchAll(PDO $pdo, string $query, array $params = []): array {
    try {
        $stmt = executeQuery($pdo, $query, $params);
        return $stmt->fetchAll();
    } catch (Exception $e) {
        logError('Error fetching multiple rows', ['query' => $query, 'error' => $e->getMessage()]);
        return [];
    }
}

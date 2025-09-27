<?php
declare(strict_types=1);

/**
 * Simple file-based caching system for Recipe Web App
 */

class SimpleCache {
    private string $cacheDir;
    private int $defaultTtl;

    public function __construct(string $cacheDir = null, int $defaultTtl = 3600) {
        $this->cacheDir = $cacheDir ?? __DIR__ . '/../../cache';
        $this->defaultTtl = $defaultTtl;

        // Create cache directory if it doesn't exist
        if (!is_dir($this->cacheDir)) {
            if (!mkdir($this->cacheDir, 0755, true)) {
                throw new Exception('Unable to create cache directory');
            }
        }
    }

    /**
     * Get cached value
     */
    public function get(string $key, $default = null) {
        $filename = $this->getFilename($key);

        if (!file_exists($filename)) {
            return $default;
        }

        $data = file_get_contents($filename);
        if ($data === false) {
            return $default;
        }

        $cached = unserialize($data);

        // Check if expired
        if ($cached['expires'] < time()) {
            $this->delete($key);
            return $default;
        }

        return $cached['value'];
    }

    /**
     * Set cached value
     */
    public function set(string $key, $value, int $ttl = null): bool {
        $ttl = $ttl ?? $this->defaultTtl;
        $filename = $this->getFilename($key);

        $data = [
            'value' => $value,
            'expires' => time() + $ttl
        ];

        return file_put_contents($filename, serialize($data), LOCK_EX) !== false;
    }

    /**
     * Delete cached value
     */
    public function delete(string $key): bool {
        $filename = $this->getFilename($key);

        if (file_exists($filename)) {
            return unlink($filename);
        }

        return true;
    }

    /**
     * Clear all cache
     */
    public function clear(): bool {
        $files = glob($this->cacheDir . '/*.cache');
        $success = true;

        foreach ($files as $file) {
            if (!unlink($file)) {
                $success = false;
            }
        }

        return $success;
    }

    /**
     * Get cache filename for key
     */
    private function getFilename(string $key): string {
        return $this->cacheDir . '/' . md5($key) . '.cache';
    }

    /**
     * Remember pattern - get from cache or execute callback
     */
    public function remember(string $key, callable $callback, int $ttl = null) {
        $value = $this->get($key);

        if ($value === null) {
            $value = $callback();
            $this->set($key, $value, $ttl);
        }

        return $value;
    }
}

/**
 * Global cache instance
 */
function getCache(): SimpleCache {
    static $cache = null;

    if ($cache === null) {
        $cache = new SimpleCache();
    }

    return $cache;
}

/**
 * Cache database query results
 */
function cacheQuery(PDO $pdo, string $query, array $params = [], int $ttl = 3600) {
    $cache = getCache();
    $cacheKey = 'query_' . md5($query . serialize($params));

    return $cache->remember($cacheKey, function() use ($pdo, $query, $params) {
        try {
            $stmt = $pdo->prepare($query);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            handleDatabaseError($e, 'cached query');
            return [];
        }
    }, $ttl);
}

/**
 * Cache categories for dropdowns
 */
function getCachedCategories(PDO $pdo): array {
    return cacheQuery($pdo, "SELECT id, name FROM categories ORDER BY name", [], 1800); // 30 minutes
}

/**
 * Cache dietary attributes for dropdowns
 */
function getCachedDietaryAttributes(PDO $pdo): array {
    return cacheQuery($pdo, "SELECT id, name, description FROM dietary_attributes ORDER BY display_order, name", [], 1800); // 30 minutes
}

/**
 * Cache tags for dropdowns
 */
function getCachedTags(PDO $pdo): array {
    return cacheQuery($pdo, "SELECT id, name FROM tags ORDER BY name", [], 1800); // 30 minutes
}

<?php
require_once __DIR__ . '/../app/includes/auth.php';
require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/db.php';
require_once __DIR__ . '/../app/includes/cache.php';
require_once __DIR__ . '/../app/includes/error_handler.php';

start_secure_session();

$id = (int)($_GET['id'] ?? 0);
$stmt = $pdo->prepare("
SELECT r.id, r.title, r.summary, r.difficulty, r.image_url, GROUP_CONCAT(c.name ORDER BY c.name SEPARATOR ', ') AS cats
FROM recipes r
LEFT JOIN recipe_categories rc ON rc.recipe_id = r.id
LEFT JOIN categories c ON c.id = rc.category_id
WHERE r.id = ?
GROUP BY r.id
");
// Validate recipe ID
$recipeId = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$recipeId || $recipeId <= 0) {
    http_response_code(400);
    require_once __DIR__ . '/../app/templates/header.php';
    echo '<div class="card"><h1>Invalid Recipe</h1><p>The recipe ID provided is invalid.</p><p><a href="index.php">← Back to Search</a></p></div>';
    require_once __DIR__ . '/../app/templates/footer.php';
    exit;
}

try {
    // Cache recipe data for 1 hour
    $cache = getCache();
    $cacheKey = "recipe_{$recipeId}";
    
    $recipeData = $cache->remember($cacheKey, function() use ($pdo, $recipeId) {
        // Fetch recipe details
        $recipe = fetchOne($pdo, "
            SELECT r.id, r.title, r.summary, r.difficulty, r.image_url,
                   GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') AS categories,
                   GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ', ') AS tags
            FROM recipes r
            LEFT JOIN recipe_categories rc ON rc.recipe_id = r.id
            LEFT JOIN categories c ON c.id = rc.category_id
            LEFT JOIN recipe_tags rt ON rt.recipe_id = r.id
            LEFT JOIN tags t ON t.id = rt.tag_id
            WHERE r.id = ?
            GROUP BY r.id
        ", [$recipeId]);
        
        if (!$recipe) {
            return null;
        }
        
        // Fetch ingredients
        $ingredients = fetchAll($pdo, "
            SELECT i.name, ri.quantity 
            FROM recipe_ingredients ri 
            JOIN ingredients i ON i.id = ri.ingredient_id 
            WHERE ri.recipe_id = ? 
            ORDER BY i.name
        ", [$recipeId]);
        
        // Fetch steps
        $steps = fetchAll($pdo, "
            SELECT step_no, instruction, minutes 
            FROM recipe_steps 
            WHERE recipe_id = ? 
            ORDER BY step_no
        ", [$recipeId]);
        
        // Fetch rating data
        $rating = fetchOne($pdo, "
            SELECT COALESCE(AVG(overall), 0) AS avg_overall,
                   COUNT(*) as rating_count,
                   COALESCE(AVG(taste), 0) as avg_taste,
                   COALESCE(AVG(aesthetics), 0) as avg_aesthetics,
                   COALESCE(AVG(difficulty_score), 0) as avg_difficulty
            FROM ratings 
            WHERE recipe_id = ?
        ", [$recipeId]);
        
        // Fetch nutrition
        $nutrition = fetchOne($pdo, "
            SELECT calories_kcal, protein_g, carbs_g, fat_g 
            FROM nutrition 
            WHERE recipe_id = ?
        ", [$recipeId]);
        
        // Calculate total time
        $totalTime = 0;
        foreach ($steps as $step) {
            $totalTime += (int)($step['minutes'] ?? 0);
        }
        
        return [
            'recipe' => $recipe,
            'ingredients' => $ingredients,
            'steps' => $steps,
            'rating' => $rating ?: ['avg_overall' => 0, 'rating_count' => 0, 'avg_taste' => 0, 'avg_aesthetics' => 0, 'avg_difficulty' => 0],
            'nutrition' => $nutrition,
            'total_time' => $totalTime
        ];
    }, 3600); // Cache for 1 hour
    
    if (!$recipeData || !$recipeData['recipe']) {
        http_response_code(404);
        require_once __DIR__ . '/../app/templates/header.php';
        echo '<div class="card"><h1>Recipe Not Found</h1><p>The recipe you\'re looking for doesn\'t exist.</p><p><a href="index.php">← Back to Search</a></p></div>';
        require_once __DIR__ . '/../app/templates/footer.php';
        exit;
    }
    
    $recipe = $recipeData['recipe'];
    $ingredients = $recipeData['ingredients'] ?? [];
    $steps = $recipeData['steps'] ?? [];
    $rating = $recipeData['rating'];
    $nutrition = $recipeData['nutrition'];
    $totalTime = $recipeData['total_time'];
    
    // Check if user is logged in for favorite functionality
    $currentUserId = current_user_id();
    $isFavorite = false;
    $userRating = null;
    
    if ($currentUserId) {
        // Check if recipe is favorited
        $favoriteCheck = fetchOne($pdo, "SELECT 1 FROM favourites WHERE user_id = ? AND recipe_id = ?", [$currentUserId, $recipeId]);
        $isFavorite = (bool)$favoriteCheck;
        
        // Get user's rating for this recipe
        $userRating = fetchOne($pdo, "SELECT overall, taste, aesthetics, difficulty_score FROM ratings WHERE user_id = ? AND recipe_id = ?", [$currentUserId, $recipeId]);
    }
    
} catch (Exception $e) {
    logError('Error loading recipe', ['recipe_id' => $recipeId, 'error' => $e->getMessage()]);
    require_once __DIR__ . '/../app/templates/header.php';
    echo '<div class="card"><h1>Error Loading Recipe</h1><p>Sorry, we couldn\'t load this recipe. Please try again later.</p><p><a href="index.php">← Back to Search</a></p></div>';
    require_once __DIR__ . '/../app/templates/footer.php';
    exit;
}

// Handle POST requests for favorites and ratings
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $currentUserId) {
    require_once __DIR__ . '/../app/includes/csrf.php';
    
    try {
        verify_csrf();
        
        if (isset($_POST['toggle_favorite'])) {
            if ($isFavorite) {
                // Remove from favorites
                executeQuery($pdo, "DELETE FROM favourites WHERE user_id = ? AND recipe_id = ?", [$currentUserId, $recipeId]);
                $isFavorite = false;
                $message = "Recipe removed from favorites.";
            } else {
                // Add to favorites
                executeQuery($pdo, "INSERT IGNORE INTO favourites (user_id, recipe_id) VALUES (?, ?)", [$currentUserId, $recipeId]);
                $isFavorite = true;
                $message = "Recipe added to favorites!";
            }
            
            // Clear cache
            $cache->delete($cacheKey);
            
            // Set success message for display
            $_SESSION['flash_message'] = $message;
            header("Location: recipe.php?id={$recipeId}");
            exit;
        }
        
        if (isset($_POST['submit_rating'])) {
            $validation = validateInput([
                'overall' => ['required' => true, 'type' => 'int', 'min' => 1, 'max' => 5, 'label' => 'Overall rating'],
                'taste' => ['type' => 'int', 'min' => 1, 'max' => 5, 'label' => 'Taste rating'],
                'aesthetics' => ['type' => 'int', 'min' => 1, 'max' => 5, 'label' => 'Aesthetics rating'],
                'difficulty_score' => ['type' => 'int', 'min' => 1, 'max' => 5, 'label' => 'Difficulty rating']
            ], $_POST);
            
            if (empty($validation['errors'])) {
                $data = $validation['data'];
                
                // Insert or update rating
                executeQuery($pdo, "
                    INSERT INTO ratings (user_id, recipe_id, overall, taste, aesthetics, difficulty_score) 
                    VALUES (?, ?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE 
                        overall = VALUES(overall),
                        taste = VALUES(taste),
                        aesthetics = VALUES(aesthetics),
                        difficulty_score = VALUES(difficulty_score),
                        updated_at = CURRENT_TIMESTAMP
                ", [
                    $currentUserId, 
                    $recipeId, 
                    $data['overall'],
                    $data['taste'] ?: null,
                    $data['aesthetics'] ?: null,
                    $data['difficulty_score'] ?: null
                ]);
                
                // Clear cache
                $cache->delete($cacheKey);
                
                $_SESSION['flash_message'] = "Rating submitted successfully!";
                header("Location: recipe.php?id={$recipeId}");
                exit;
            } else {
                $errors = $validation['errors'];
            }
        }
        
    } catch (Exception $e) {
        logError('Error processing recipe action', ['recipe_id' => $recipeId, 'action' => $_POST, 'error' => $e->getMessage()]);
        $errors = ['An error occurred while processing your request.'];
    }
}

require_once __DIR__ . '/../app/templates/header.php';

// Display flash message
if (!empty($_SESSION['flash_message'])) {
    echo '<div class="card" style="background: #d1f2eb; border-color: #27ae60; color: #27ae60;">' . e($_SESSION['flash_message']) . '</div>';
    unset($_SESSION['flash_message']);
}

// Display errors
if (!empty($errors)) {
    echo '<div class="card" role="alert" style="background: #ffeaa7; border-color: #e17055;"><ul>';
    foreach ($errors as $error) {
        echo '<li>' . e($error) . '</li>';
    }
    echo '</ul></div>';
}
?>

<article class="card">
    <header>
        <?php if (!empty($recipe['image_url'])): ?>
            <img src="<?= e($recipe['image_url']) ?>" 
                 alt="<?= e($recipe['title']) ?>" 
                 style="width:100%;max-height:360px;object-fit:cover;border-radius:8px;margin-bottom:1rem;"
                 onerror="this.style.display='none'">
        <?php endif; ?>
        
        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 1rem;">
            <div style="flex: 1;">
                <h1><?= e($recipe['title']) ?></h1>
                <div class="meta">
                    <?= e($recipe['difficulty']) ?> · 
                    <?= $totalTime ?> minutes total · 
                    Categories: <?= e($recipe['categories'] ?? 'None') ?>
                    <?php if (!empty($recipe['tags'])): ?>
                        <br>Tags: <?= e($recipe['tags']) ?>
                    <?php endif; ?>
                </div>
            </div>
            
            <?php if ($currentUserId): ?>
                <div style="display: flex; gap: 0.5rem;">
                    <form method="post" style="margin: 0;">
                        <?= csrf_field() ?>
                        <button type="submit" name="toggle_favorite" 
                                style="background: <?= $isFavorite ? '#e74c3c' : '#3498db' ?>; color: white; border: none; padding: 0.5rem 1rem; border-radius: 4px; cursor: pointer;">
                            <?= $isFavorite ? '❤️ Favorited' : '🤍 Add to Favorites' ?>
                        </button>
                    </form>
                </div>
            <?php endif; ?>
        </div>
        
        <div class="meta" style="display: flex; gap: 2rem; flex-wrap: wrap; margin-bottom: 1rem;">
            <div>
                <strong>Overall Rating:</strong> ★ <?= number_format((float)$rating['avg_overall'], 1) ?>
                <?php if ($rating['rating_count'] > 0): ?>
                    (<?= (int)$rating['rating_count'] ?> review<?= $rating['rating_count'] !== 1 ? 's' : '' ?>)
                <?php endif; ?>
            </div>
            
            <?php if ($rating['avg_taste'] > 0): ?>
                <div><strong>Taste:</strong> ★ <?= number_format((float)$rating['avg_taste'], 1) ?></div>
            <?php endif; ?>
            
            <?php if ($rating['avg_aesthetics'] > 0): ?>
                <div><strong>Looks:</strong> ★ <?= number_format((float)$rating['avg_aesthetics'], 1) ?></div>
            <?php endif; ?>
            
            <?php if ($rating['avg_difficulty'] > 0): ?>
                <div><strong>Actual Difficulty:</strong> ★ <?= number_format((float)$rating['avg_difficulty'], 1) ?></div>
            <?php endif; ?>
        </div>
    </header>
    
    <?php if (!empty($recipe['summary'])): ?>
        <p><?= e($recipe['summary']) ?></p>
    <?php endif; ?>

    <?php if ($nutrition): ?>
        <h2>Nutrition Information</h2>
        <table class="table" aria-describedby="nutri-caption">
            <caption id="nutri-caption" class="sr-only">Per serving nutrition facts</caption>
            <thead>
                <tr>
                    <th>Calories (kcal)</th>
                    <th>Protein (g)</th>
                    <th>Carbohydrates (g)</th>
                    <th>Fat (g)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><?= (int)$nutrition['calories_kcal'] ?></td>
                    <td><?= number_format((float)$nutrition['protein_g'], 1) ?></td>
                    <td><?= number_format((float)$nutrition['carbs_g'], 1) ?></td>
                    <td><?= number_format((float)$nutrition['fat_g'], 1) ?></td>
                </tr>
            </tbody>
        </table>
    <?php endif; ?>

    <h2>Ingredients</h2>
    <?php if (!empty($ingredients)): ?>
        <ul>
            <?php foreach ($ingredients as $ingredient): ?>
                <li><?= e($ingredient['quantity']) ?> — <?= e($ingredient['name']) ?></li>
            <?php endforeach; ?>
        </ul>
    <?php else: ?>
        <p class="meta">No ingredients listed.</p>
    <?php endif; ?>

    <h2>Instructions</h2>
    <?php if (!empty($steps)): ?>
        <ol>
            <?php foreach ($steps as $step): ?>
                <li>
                    <strong>Step <?= (int)$step['step_no'] ?> (<?= (int)$step['minutes'] ?> min):</strong> 
                    <?= e($step['instruction']) ?>
                </li>
            <?php endforeach; ?>
        </ol>
        <p class="meta"><strong>Total cooking time:</strong> <?= $totalTime ?> minutes</p>
    <?php else: ?>
        <p class="meta">No instructions available.</p>
    <?php endif; ?>
</article>

<?php if ($currentUserId): ?>
    <div class="card">
        <h2>Rate this Recipe</h2>
        <?php if ($userRating): ?>
            <p class="meta">You've already rated this recipe. Submit a new rating to update it.</p>
        <?php endif; ?>
        
        <form method="post" class="needs-validate" novalidate>
            <?= csrf_field() ?>
            
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                <div>
                    <label for="overall">Overall Rating (1-5)*</label>
                    <select id="overall" name="overall" required>
                        <option value="">Choose rating</option>
                        <option value="1" <?= $userRating && $userRating['overall'] == 1 ? 'selected' : '' ?>>1 - Poor</option>
                        <option value="2" <?= $userRating && $userRating['overall'] == 2 ? 'selected' : '' ?>>2 - Fair</option>
                        <option value="3" <?= $userRating && $userRating['overall'] == 3 ? 'selected' : '' ?>>3 - Good</option>
                        <option value="4" <?= $userRating && $userRating['overall'] == 4 ? 'selected' : '' ?>>4 - Very Good</option>
                        <option value="5" <?= $userRating && $userRating['overall'] == 5 ? 'selected' : '' ?>>5 - Excellent</option>
                    </select>
                </div>
                
                <div>
                    <label for="taste">Taste (1-5)</label>
                    <select id="taste" name="taste">
                        <option value="">Not rated</option>
                        <option value="1" <?= $userRating && $userRating['taste'] == 1 ? 'selected' : '' ?>>1 - Poor</option>
                        <option value="2" <?= $userRating && $userRating['taste'] == 2 ? 'selected' : '' ?>>2 - Fair</option>
                        <option value="3" <?= $userRating && $userRating['taste'] == 3 ? 'selected' : '' ?>>3 - Good</option>
                        <option value="4" <?= $userRating && $userRating['taste'] == 4 ? 'selected' : '' ?>>4 - Very Good</option>
                        <option value="5" <?= $userRating && $userRating['taste'] == 5 ? 'selected' : '' ?>>5 - Excellent</option>
                    </select>
                </div>
                
                <div>
                    <label for="aesthetics">Appearance (1-5)</label>
                    <select id="aesthetics" name="aesthetics">
                        <option value="">Not rated</option>
                        <option value="1" <?= $userRating && $userRating['aesthetics'] == 1 ? 'selected' : '' ?>>1 - Poor</option>
                        <option value="2" <?= $userRating && $userRating['aesthetics'] == 2 ? 'selected' : '' ?>>2 - Fair</option>
                        <option value="3" <?= $userRating && $userRating['aesthetics'] == 3 ? 'selected' : '' ?>>3 - Good</option>
                        <option value="4" <?= $userRating && $userRating['aesthetics'] == 4 ? 'selected' : '' ?>>4 - Very Good</option>
                        <option value="5" <?= $userRating && $userRating['aesthetics'] == 5 ? 'selected' : '' ?>>5 - Excellent</option>
                    </select>
                </div>
                
                <div>
                    <label for="difficulty_score">Actual Difficulty (1-5)</label>
                    <select id="difficulty_score" name="difficulty_score">
                        <option value="">Not rated</option>
                        <option value="1" <?= $userRating && $userRating['difficulty_score'] == 1 ? 'selected' : '' ?>>1 - Very Easy</option>
                        <option value="2" <?= $userRating && $userRating['difficulty_score'] == 2 ? 'selected' : '' ?>>2 - Easy</option>
                        <option value="3" <?= $userRating && $userRating['difficulty_score'] == 3 ? 'selected' : '' ?>>3 - Medium</option>
                        <option value="4" <?= $userRating && $userRating['difficulty_score'] == 4 ? 'selected' : '' ?>>4 - Hard</option>
                        <option value="5" <?= $userRating && $userRating['difficulty_score'] == 5 ? 'selected' : '' ?>>5 - Very Hard</option>
                    </select>
                </div>
            </div>
            
            <button type="submit" name="submit_rating" style="margin-top: 1rem;">
                <?= $userRating ? 'Update Rating' : 'Submit Rating' ?>
            </button>
        </form>
    </div>
<?php else: ?>
    <div class="card">
        <p class="meta">
            <a href="login.php">Login</a> or <a href="register.php">register</a> to rate this recipe and add it to your favorites.
        </p>
    </div>
<?php endif; ?>

<div class="card">
    <p><a href="index.php">← Back to Search</a> | <a href="search.php">Browse All Recipes</a></p>
</div>

<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>

global$pdo; global$pdo; global$pdo;
<?php
require_once __DIR__ . '/../app/includes/auth.php';
require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/db.php';
require_once __DIR__ . '/../app/includes/cache.php';
require_once __DIR__ . '/../app/includes/error_handler.php';

start_secure_session();

try {
    // Use cached categories, dietary attributes, and tags for better performance
    $categories = getCachedCategories($pdo);
    $dietaryAttributes = getCachedDietaryAttributes($pdo);
    $tags = getCachedTags($pdo);
} catch (Exception $e) {
    logError('Error loading homepage data', ['error' => $e->getMessage()]);
    $categories = [];
    $dietaryAttributes = [];
    $tags = [];
}

require_once __DIR__ . '/../app/templates/header.php';
?>
<section class="card">
    <h1>Find your next favourite recipe</h1>
    <p class="meta">Search by keyword, category, dietary needs, ingredients, time, tags, and nutrition.</p>

    <form class="grid cols-2" action="search.php" method="get" novalidate>
        <div>
            <label for="q">Keyword</label>
            <input id="q" type="text" name="q" placeholder="e.g. vegan, pasta" maxlength="100">
        </div>

        <div>
            <label for="category">Category</label>
            <select id="category" name="category">
                <option value="">Any</option>
                <?php foreach ($categories as $cat): ?>
                    <option value="<?= e($cat['id']) ?>"><?= e($cat['name']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label for="dietary">Dietary Needs</label>
            <select id="dietary" name="dietary">
                <option value="">Any</option>
                <?php foreach ($dietaryAttributes as $attr): ?>
                    <option value="<?= e($attr['id']) ?>" title="<?= e($attr['description'] ?? '') ?>">
                        <?= e($attr['name']) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label for="include_ing">Include ingredient</label>
            <input id="include_ing" type="text" name="include_ing" placeholder="e.g. tomato" maxlength="50">
        </div>

        <div>
            <label for="exclude_ing">Exclude ingredient</label>
            <input id="exclude_ing" type="text" name="exclude_ing" placeholder="e.g. nuts" maxlength="50">
        </div>

        <div>
            <label for="time_max">Max total time (minutes)</label>
            <input id="time_max" type="number" min="1" max="1440" name="time_max" placeholder="e.g. 45">
        </div>

        <div>
            <label for="difficulty">Difficulty</label>
            <select id="difficulty" name="difficulty">
                <option value="">Any</option>
                <option value="Easy">Easy</option>
                <option value="Medium">Medium</option>
                <option value="Hard">Hard</option>
            </select>
        </div>

        <div>
            <label for="tag">Tag</label>
            <select id="tag" name="tag">
                <option value="">Any</option>
                <?php foreach ($tags as $tag): ?>
                    <option value="<?= e($tag['id']) ?>"><?= e($tag['name']) ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div>
            <label for="cal_min">Min calories (kcal)</label>
            <input id="cal_min" type="number" min="0" max="5000" name="cal_min">
        </div>

        <div>
            <label for="cal_max">Max calories (kcal)</label>
            <input id="cal_max" type="number" min="0" max="5000" name="cal_max">
        </div>

        <div>
            <label for="protein_min">Min protein (g)</label>
            <input id="protein_min" type="number" min="0" max="500" step="0.1" name="protein_min">
        </div>

        <div>
            <label for="sort">Sort by</label>
            <select id="sort" name="sort">
                <option value="relevance">Relevance</option>
                <option value="time_asc">Total time (asc)</option>
                <option value="time_desc">Total time (desc)</option>
                <option value="rating_desc">Rating (desc)</option>
            </select>
        </div>

        <div style="align-self:end;">
            <button type="submit">Search</button>
        </div>
    </form>
</section>

<?php if (empty($categories) && empty($dietaryAttributes) && empty($tags)): ?>
    <section class="card">
        <p class="meta">⚠️ Some features may be limited due to a temporary issue. Please try again later.</p>
    </section>
<?php endif; ?>

<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>

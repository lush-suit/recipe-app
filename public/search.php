<?php
require_once __DIR__ . '/../app/includes/auth.php';
require_once __DIR__ . '/../app/includes/utils.php';
require_once __DIR__ . '/../app/includes/db.php';
require_once __DIR__ . '/../app/templates/header.php';

$q = trim($_GET['q'] ?? '');
$category = trim($_GET['category'] ?? '');
$dietary = trim($_GET['dietary'] ?? ''); // new dietary filter from homepage
$include = trim($_GET['include_ing'] ?? '');
$exclude = trim($_GET['exclude_ing'] ?? '');
$time_max = trim($_GET['time_max'] ?? '');
$difficulty = trim($_GET['difficulty'] ?? '');
$tag = trim($_GET['tag'] ?? '');
$cal_min = trim($_GET['cal_min'] ?? '');
$cal_max = trim($_GET['cal_max'] ?? '');
$protein_min = trim($_GET['protein_min'] ?? '');
$sort = $_GET['sort'] ?? 'relevance';

$sql = "
SELECT r.id, r.title, r.difficulty, r.image_url,
       COALESCE(AVG(rt.overall),0) as avg_rating,
       -- realistic total time: sum of max minutes per step group
       (SELECT total_minutes FROM recipe_timing WHERE recipe_id = r.id) AS total_time
FROM recipes r
LEFT JOIN ratings rt ON rt.recipe_id = r.id
LEFT JOIN recipe_categories rc ON rc.recipe_id = r.id
LEFT JOIN recipe_tags rtag ON rtag.recipe_id = r.id
LEFT JOIN tags t ON t.id = rtag.tag_id
LEFT JOIN nutrition n ON n.recipe_id = r.id
";
$conds = [];
$params = [];

if ($q !== '') {
    // Prefer full-text if available, fallback to LIKE pattern
    $conds[] = "(MATCH(r.title, r.summary) AGAINST (? IN NATURAL LANGUAGE MODE) OR r.title LIKE ? OR r.summary LIKE ?)";
    $params[] = $q;
    $params[] = "%$q%";
    $params[] = "%$q%";
}

if ($category !== '') { $conds[] = "rc.category_id = ?"; $params[] = (int)$category; }

if ($dietary !== '') {
    $sql .= " JOIN recipe_dietary_attributes rda ON rda.recipe_id = r.id ";
    $conds[] = "rda.dietary_attribute_id = ? AND (rda.confidence IN ('verified','likely'))";
    $params[] = (int)$dietary;
}

if ($include !== '') {
    // Join ingredients + synonyms to improve matching
    $sql .= " LEFT JOIN recipe_ingredients ri_inc ON ri_inc.recipe_id = r.id
              LEFT JOIN ingredients i_inc ON i_inc.id = ri_inc.ingredient_id
              LEFT JOIN ingredient_synonyms syn_inc ON syn_inc.ingredient_id = i_inc.id ";
    $conds[] = "(i_inc.name LIKE ? OR syn_inc.synonym LIKE ?)";
    $params[] = "%$include%";
    $params[] = "%$include%";
}

if ($exclude !== '') {
    // Exclude if any ingredient OR its synonym matches the exclusion text
    $conds[] = "r.id NOT IN (
        SELECT r2.id
        FROM recipes r2
        JOIN recipe_ingredients ri2 ON ri2.recipe_id = r2.id
        JOIN ingredients i2 ON i2.id = ri2.ingredient_id
        LEFT JOIN ingredient_synonyms syn2 ON syn2.ingredient_id = i2.id
        WHERE i2.name LIKE ? OR syn2.synonym LIKE ?
    )";
    $params[] = "%$exclude%";
    $params[] = "%$exclude%";
}

if ($time_max !== '') {
    // Use view for realistic time filtering
    $conds[] = "r.id IN (SELECT recipe_id FROM recipe_timing WHERE total_minutes <= ?)";
    $params[] = (int)$time_max;
}

if ($difficulty !== '') { $conds[] = "r.difficulty = ?"; $params[] = $difficulty; }
if ($tag !== '') { $conds[] = "t.id = ?"; $params[] = (int)$tag; }
if ($cal_min !== '') { $conds[] = "n.calories_kcal >= ?"; $params[] = (int)$cal_min; }
if ($cal_max !== '') { $conds[] = "n.calories_kcal <= ?"; $params[] = (int)$cal_max; }
if ($protein_min !== '') { $conds[] = "n.protein_g >= ?"; $params[] = (int)$protein_min; }

if ($conds) { $sql .= " WHERE " . implode(" AND ", $conds); }

$sql .= " GROUP BY r.id ";
switch ($sort) {
  case 'time_asc': $sql .= " ORDER BY total_time ASC"; break;
  case 'time_desc': $sql .= " ORDER BY total_time DESC"; break;
  case 'rating_desc': $sql .= " ORDER BY avg_rating DESC"; break;
  default: $sql .= " ORDER BY avg_rating DESC, r.title ASC"; break;
}

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$results = $stmt->fetchAll();
?>
<h1>Search results</h1>
<?php if (!$results): ?>
  <p class="meta">No recipes found. Try broadening your filters.</p>
<?php else: ?>
  <div class="grid cols-2">
    <?php foreach($results as $r): ?>
      <a class="card" href="recipe.php?id=<?= e($r['id'])?>">
        <?php if (!empty($r['image_url'])): ?><img src="<?= e($r['image_url'])?>" alt="" style="width:100%;height:160px;object-fit:cover;border-radius:6px;margin-bottom:.5rem;"><?php endif; ?>
        <strong><?= e($r['title'])?></strong>
        <div class="meta"><?= e($r['difficulty'])?> · <?= (int)$r['total_time'] ?> mins · ★ <?= number_format((float)$r['avg_rating'], 1) ?></div>
      </a>
    <?php endforeach; ?>
  </div>
<?php endif; ?>
<?php require_once __DIR__ . '/../app/templates/footer.php'; ?>
